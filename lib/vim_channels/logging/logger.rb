# frozen_string_literal: true

require "vim_channels/logging/thread_safe_level"
require "logger"

module VimChannels
  module Logging
    # Logger class
    # TODO: Document more
    class Logger < ::Logger
      include ThreadSafeLevel

      def initialize(*args, **options)
        super
        @formatter = SimpleFormatter.new
      end

      # Simple formatter which only displays the message
      class SimpleFormatter < ::Logger::Formatter
        # This method is invoked when a log event occurs
        def call(_severity, _timestamp, _progname, msg)
          "#{msg.is_a?(String) ? msg : msg.inspect}\n"
        end
      end
    end
  end
end
