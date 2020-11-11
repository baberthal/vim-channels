# frozen_string_literal: true

require "concurrent"
require "fiber"

module VimChannels
  module Logging
    # Thread-safe get and set of logger levels.
    #
    # @api private
    module ThreadSafeLevel
      def self.included(base)
        class << base; attr_accessor :local_levels; end
        base.local_levels = Concurrent::Map.new(initial_capacity: 2)
      end

      Logger::Severity.constants.each do |severity|
        class_eval(<<-METHOD, __FILE__, __LINE__ + 1)
          def #{severity.downcase}?           # def debug?
            Logger::#{severity} >= level      #   DEBUG >= level
          end                                 # end
        METHOD
      end

      def local_log_id
        Fiber.current.__id__
      end

      def local_level
        self.class.local_levels[local_log_id]
      end

      def local_level=(level) # rubocop:disable Metrics/AbcSize
        case level
        when Integer
          self.class.local_levels[local_log_id] = level
        when Symbol
          self.class.local_levels[local_log_id] =
            Logger::Severity.const_get(level.to_s.upcase)
        when nil
          self.class.local_levels.delete(local_log_id)
        else
          raise ArgumentError, "Invalid log level: #{level.inspect}"
        end
      end

      def level
        local_level || super
      end

      def add(severity, message = nil, progname = nil, &_block)
        severity ||= UNKNOWN
        progname ||= @progname

        return true if @logdev.nil? || severity < level

        if message.nil?
          if block_given?
            message = yield
          else
            message  = progname
            progname = @progname
          end
        end

        @logdev.write \
          format_message(format_severity(severity), Time.now, progname, message)
      end
    end
  end
end
