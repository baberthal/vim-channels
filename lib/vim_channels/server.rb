# frozen_string_literal: true

require "forwardable"

module VimChannels
  # Server for TCP Channels
  # TODO: Add way more documentation
  class Server
    include Logging
    extend Forwardable

    # Default timeout for the server, in seconds.
    DEFAULT_TIMEOUT                        = 30
    # Default host to which the server will be bound.
    DEFAULT_HOST                           = "0.0.0.0"
    # Default port for the server to listen on.
    DEFAULT_PORT                           = 1337
    # Default number of maximum connections the server will accept.
    DEFAULT_MAXIMUM_CONNECTIONS            = 1024

    # Application (i.e. handler) that is called with responses from vim
    #
    # @return [#call]
    attr_accessor :app

    # Backend handling the connections to the client.
    #
    # @return [Backends::Base]
    attr_accessor :backend

    # @!attribute [rw] timeout
    #   Maximum number of seconds for incoming data to arrive before the
    #   conneciton is dropped.
    #   @return [Integer]
    def_delegators :backend, :timeout, :timeout=

    # @!attribute [rw] maximum_connections
    #   Maximum number of file or socket descriptors that the server may open.
    #   @return [Integer]
    def_delegators :backend, :maximum_connections, :maximum_connections=

    # @!attribute [w] threaded
    #   Allows use of threads in the backend.
    #   @return [Boolean]
    # @!method threaded?
    #   Allows use of threads in the backend.
    #   @return [Boolean]
    def_delegators :backend, :threaded?, :threaded=

    # @!attribute [rw] threadpool_size
    #   Allows setting of EventMachine threadpool size
    #   @return [Integer]
    def_delegators :backend, :threadpool_size, :threadpool_size=

    # @!attribute [r] host
    #   Address on which the server is listening for connections.
    #   @return [String]
    #
    # @!attribute [r] port
    #   Port on which the server is listening for connections.
    #   @return [Integer]
    def_delegators :backend, :host, :port

    # @!attribute [r] socket
    #   Unix domain socket on which the server is listening for connections.
    #   @return [Socket]
    def_delegator :backend, :socket

    # @!attribute [r] stdio
    #   Returns true if the server operates over stdio.
    #   @return [Boolean]
    #
    # @!method stdio?
    #   Returns true if the server operates over stdio.
    #   @return [Boolean]
    def_delegators :backend, :stdio, :stdio?

    # @!attribute [rw] no_epoll
    #   Disable use of epoll on Linux.
    #   @return [Boolean]
    def_delegators :backend, :no_epoll, :no_epoll=

    # @overload initialize(host, port, app)
    #   Create a new server bound to +host+, listening on +port+ and using +app+
    #   to handle requests and responses.
    #   @param host [String] Host to bind the server to
    #   @param port [Integer] Port to listen on
    #   @param app [#call] Rack-style app to handle requests/responses
    #
    # @overload initialize(host, app)
    #   Create a new server, bound to +host+, using the default port, and using
    #   +app+ to handle requests and responses.
    #   @param host [String] Host to bind the server to
    #   @param app [#call] Rack-style app to handle requests/responses
    #
    # @overload initialize(port, app)
    #   Create a new server, bound to the default host +("0.0.0.0")+, listening
    #   on +port+, and using +app+ to handle requests and responses.
    #   @param port [Integer] Port to listen on
    #   @param app [#call] Rack-style app to handle requests/responses
    #
    # @overload initialize(app)
    #   Create a new server bound to the default host +("0.0.0.0")+, listening on
    #   the default port (1337), using +app+ to handle requests and responses.
    #   @param app [#call] Rack-style app to handle requests/responses
    def initialize(*args)
      host, port, options = DEFAULT_HOST, DEFAULT_PORT, {}

      # Guess each parameter by its type so they can be received in any order
      args.each do |arg|
        case arg
        when 0.class, /^\d+$/ then port    = arg.to_i
        when String           then host    = arg
        when Hash             then options = arg
        else
          @app = arg if arg.respond_to?(:call)
        end
      end

      @backend = select_backend(host, port, options)

      @backend.server = self

      # Set defaults
      @backend.maximum_connections = DEFAULT_MAXIMUM_CONNECTIONS
      @backend.timeout             = DEFAULT_TIMEOUT

      @setup_signals = options[:signals] != false
    end

    # Shortcut to turn this:
    #
    #   Server.new(...).start
    #
    # into this:
    #
    #   Server.start(...)
    #
    # @see #initialize
    def self.start(*args, &block)
      new(*args, &block).start!
    end

    # Start the server and listen for connections.
    def start
      raise ArgumentError, "app required" unless @app

      log_info  "VimChannels server (v#{VERSION})"
      log_debug "Debugging ON"
      trace     "Tracing ON"

      log_info "Maximum connections set to #{backend.maximum_connections}"
      log_info "Listening on #{backend}, CTRL+C to stop"

      @backend.start { setup_signals if @setup_signals }
    end
    alias start! start

    # Graceful Shutdown.
    #
    # Stops the server after processing all current connections.
    # As soon as this method is called, the server stops accepting new requests
    # and waits for all current connections to finish.
    #
    # @note Calling twice is the equivalent to calling {#stop!}
    def stop; end

    # Force Shutdown.
    #
    # Stops the server, closing all open connections right away.
    # This doesn't wait for connections to finish their work and send data.
    # All current connections will be dropped.
    def stop!; end

    # Configure the server.
    #
    # This process might need to have superuser privleges to configure server
    # with optimal options.
    def config
      @backend.config
    end

    # Name of the server and the type of backend used.
    def name
      "vim-channels server (#{@backend})"
    end
    alias to_s name

    # Returns +true+ if the server is running and ready to receive requests.
    # Note that the server might still be running and return +false+ when
    # shutting down and waiting for active connections to complete.
    #
    # @return [Boolean]
    def running?
      @backend.running?
    end

  protected

    def setup_signals
      # Queue up signals, so they are processed in non-trap context using EM
      # timer.
      @signal_queue = []

      %w[INT TERM].each do |signal|
        trap(signal) { @signal_queue.push(signal) }
      end

      # *nix-only signals
      %w[QUIT HUP USR1].each do |signal|
        trap(signal) { @signal_queue.push(signal) }
      end

      # Signals are processed at one-second intervals.
      @signal_timer ||= EM.add_periodic_timer(1) { handle_signals }

      nil
    end

    def handle_signals
      case @signal_queue.shift
      when "INT"
        stop!
      when "TERM", "QUIT"
        stop
      when "HUP"
        restart
      when "USR1"
        reopen_log
      end

      EM.next_tick { handle_signals } unless @signal_queue.empty?
    end

    def select_backend(host, port, options)
      if options.key?(:backend)
        unless options[:backend].is_a?(Class)
          raise ArgumentError, ":backend must be a class"
        end

        options[:backend].new(host, port, options)
      elsif /^std(out|io)$/.match?(host)
        Backends::StdioServer.new(options)
      else
        Backends::TcpServer.new(host, port)
      end
    end
  end
end
