# frozen_string_literal: true

module VimChannels
  module Backends
    # Class for STDIO-based backend
    class StdioServer < Base
      def to_s
        "STDIO"
      end
    end
  end
end
