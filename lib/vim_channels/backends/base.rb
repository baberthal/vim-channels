# frozen_string_literal: true

module VimChannels
  module Backends
    # A backend connects the server to a client. It handles:
    # * connection/disconnection to and from the server
    # * initialization of the connections
    # * monitoring of the active connections.
    #
    # == Implementing your own backend
    #
    # You can create your own minimal backend by inheriting this class and
    # defining the following methods:
    #
    # * {#connect}
    # * {#disconnect}
    #
    # Additionally, if your backend is not based on EventMachine, you also need
    # to implement the following methods:
    #
    # * {#start}
    # * {#stop}
    # * {#stop!}
    # * {#config}
    #
    class Base
      # Server serving the connections through the backend.
      #
      # @return [Server]
      attr_accessor :server

      # Maximum time to wait for incoming data to arrive.
      #
      # @return [Integer]
      attr_accessor :timeout

      # Maximum number of file or socket descriptors that the server may open.
      #
      # @return [Integer]
      attr_accessor :maximum_connections

      # Maximum number of connections that can persist.
      #
      # @return [Integer]
      attr_accessor :maximum_persistent_connections

      # Allows setting of the eventmachine threadpool size.
      #
      # @return [Integer]
      attr_reader :threadpool_size

      # (see #threadpool_size)
      def threadpool_size=(size)
        @threadpool_size = size
        EventMachine.threadpool_size = size
      end

      # Allows use of threads in the backend.
      #
      # @return [Boolean]
      attr_accessor :threaded
      alias threaded? threaded

      # Disable the use of epoll in Linux
      #
      # @return [Boolean]
      attr_accessor :no_epoll
      alias no_epoll? no_epoll

      def initialize
        @connections         = {}
        @timeout             = Server::DEFAULT_TIMEOUT
        @maximum_connections = Server::DEFAULT_MAXIMUM_CONNECTIONS
        @maximum_persistent_connections =
          Server::DEFAULT_MAXIMUM_PERSISTENT_CONNECTIONS
        @no_epoll            = false
        @running             = false
        @started_reactor     = false
        @stopping            = false
        @threaded            = nil
      end

      # Start the backend and connect to it.
      #
      # @return [void]
      def start
        @stopping = false
        starter   = proc do
          connect
          yield if block_given?
          @running = true
        end

        # Allow for early run up of eventmachine
        if EventMachine.reactor_running?
          starter.call
        else
          @started_reactor = true
          EventMachine.run(&starter)
        end
      end

      # Stop the backend from accepting any new connections.
      #
      # @return [void]
      def stop
        @running  = false
        @stopping = true

        # Do not accept any more connections
        disconnect

        # Close idle connections
        @connections.each_value { |conn| conn.close_connection if conn.idle? }
        stop! if @connections.empty?
      end

      # Force stop of the backend NOW.
      #
      # @return [void]
      def stop!
        @running  = false
        @stopping = false

        EventMachine.stop if @started_reactor && EventMachine.reactor_running?
        @connections.each_value(&:close_connection)
        close
      end

      # Configure the backend. This method will be called before dropping
      # superuser privileges, so you can do lots of stuff here.
      #
      # @return [void]
      def config
        # See http://rubyeventmachine.com/pub/rdoc/files/EPOLL.html
        EventMachine.epoll unless no_epoll?

        # Set the maximum number of socket descriptors that the server may open.
        # The process needs to have the required privileges to set it higher
        # than 1024 on some systems.
        return if VimChannels.win?

        @maximum_connections =
          EventMachine.set_descriptor_table_size(@maximum_connections)
      end

      # Free up resources used by the backend.
      #
      # @return [void]
      def close; end

      # Returns +true+ if the backend is connected and running.
      #
      # @return [Boolean]
      def running?
        @running
      end

      # Returns +true+ if we started the EventMachine reactor.
      #
      # @return [Boolean]
      def started_reactor?
        @started_reactor
      end

      # Called by a connection when it's unbinded.
      #
      # @return [void]
      def connection_finished(conn)
        @connections.delete(conn.__id__)

        # Finalize graceful stop if there are no more active connections.
        stop! if @stopping && @connections.empty?
      end

      # Returns `true` if no active connections exist.
      #
      # @return [Boolean]
      def empty?
        @connections.empty?
      end

      # Returns the number of active connections.
      #
      # @return [Boolean]
      def size
        @connections.size
      end

      # Connect to the server. MUST be implemented by subclasses.
      #
      # @return [void]
      def connect
        raise NotImplementedError
      end

      # Disconnect from the server and stop it. MUST be implemented by
      # subclasses.
      #
      # @return [void]
      def disconnect
        raise NotImplementedError
      end

    protected

      # Initialize a new connection to the client.
      #
      # @param conn [Connection] The connection to initialize
      def initialize_connection(conn)
        conn.backend  = self
        conn.app      = @server.app
        conn.threaded = @threaded

        @connections[conn.__id__] = conn
      end
    end
  end
end
