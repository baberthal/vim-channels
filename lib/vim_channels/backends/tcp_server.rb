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

      def to_s
        "#{@host}:#{@port}"
      end

      def connect; end

      def disconnect; end
    end
  end
end
