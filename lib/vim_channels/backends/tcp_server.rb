# frozen_string_literal: true

require "socket"

module VimChannels
  module Backends
    # Backend to act as a TCP socket server.
    class TcpServer < Base
      # Initialize a new TcpServer backend.
      #
      # @param host [String] Host to bind the server to
      # @param port [Integer] Port for the server to listen on
      def initialize(host, port)
        @host = host
        @port = port
        super()
      end

      # Returns a string describing what host the server is bound to, and what
      # port it is listening on.
      def to_s
        "#{@host}:#{@port}"
      end

      # Connects the backend to the server.
      def connect; end

      # Disconnects the backend from the server.
      def disconnect; end
    end
  end
end
