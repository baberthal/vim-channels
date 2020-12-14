# frozen_string_literal: true

module VimChannels
  module Backends
    # Class for STDIO-based backend
    class StdioServer < Base
      def initialize(*)
        super()
      end

      # Returns a string describing the backend.
      def to_s
        "STDIO"
      end

      def stdio
        true
      end
      alias stdio? stdio
    end
  end
end
