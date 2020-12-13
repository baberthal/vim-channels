# frozen_string_literal: true

module VimChannels
  module Backends
    # A backend connects the server to a client. It handles:
    # * connection/disconnection to and from the server
    # * initialization of the connections
    # * monitoring of the active connections.
    #
    # Implementing your own backend
    # You can create your own minimal backend by inheriting this class and
    # defining the following methods:
    #
    # * {#connect}
    # * {#disconnect}
    # * {#start}
    # * {#stop}
    # * {#stop!}
    # * {#config}
    #
    class Base
      # Server serving the connections through the backend.
      # @return [Server]
      attr_accessor :server

      # Maximum time to wait for incoming data to arrive.
      # @return [Integer]
      attr_accessor :timeout

      # Maximum number of file or socket descriptors that the server may open.
      # @return [Integer]
      attr_accessor :maximum_connections

      # Allows use of threads in the backend.
      #
      # @return [Boolean]
      attr_writer :threaded

      # (see #threaded=)
      def threaded?
        @threaded
      end

      def initialize
        @connections         = {}
        @timeout             = Server::DEFAULT_TIMEOUT
        @maximum_connections = Server::DEFAULT_MAXIMUM_CONNECTIONS
        @running             = false
        @stopping            = false
        @threaded            = nil
      end

      # Start the backend and connect to it.
      #
      # @return [void]
      def start
        @stopping = false
        connect
        yield if block_given?
        @running = true
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

        @connections.each_value(&:close_connection)
        close
      end

      # Configure the backend.
      #
      # @return [void]
      def config; end

      # Free up resources used by the backend.
      #
      # @return [void]
      def close; end

      # Returns `true` if the backend is connected and running.
      #
      # @return [Boolean]
      def running?
        @running
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
