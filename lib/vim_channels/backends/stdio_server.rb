# frozen_string_literal: true

module VimChannels
  module Backends
    # Class for STDIO-based backend
    class StdioServer < Base
      # Returns a string describing the backend.
      def to_s
        "STDIO"
      end
    end
  end
end
