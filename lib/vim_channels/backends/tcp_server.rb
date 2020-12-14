# frozen_string_literal: true

module VimChannels
  module Backends
    # Backend to act as a TCP socket server.
    class TcpServer < Base
      # Address on which the server is listening for connections.
      #
      # @return [String]
      attr_accessor :host

      # Port on which the server is listening for connections.
      #
      # @return [Integer]
      attr_accessor :port

      # Initialize a new TcpServer backend.
      #
      # @param host [String] Host to bind the server to
      # @param port [Integer] Port for the server to listen on
      def initialize(host, port)
        @host = host
        @port = port
        super()
      end

      # Connects the server.
      def connect
        @signature = EventMachine.start_server(@host, @port, Connection,
                                               &method(:initialize_connection))
        binary_name = EventMachine.get_sockname(@signature)
        port_name = Socket.unpack_sockaddr_in(binary_name)
        @port = port_name[0]
        @host = port_name[1]
        @signature
      end

      # Stops the server.
      def disconnect
        EventMachine.stop_server(@signature)
      end

      # Returns a string describing what host the server is bound to, and what
      # port it is listening on.
      def to_s
        "#{@host}:#{@port}"
      end
    end
  end
end
