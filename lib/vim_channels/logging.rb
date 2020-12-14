# frozen_string_literal: true

require "logger"

module VimChannels
  # Module to hold logging abstractions.
  module Logging
    # Simple formatter which only displays the message
    class SimpleFormatter < ::Logger::Formatter
      # This method is invoked when a log event occurs
      def call(_severity, _timestamp, _progname, msg)
        "#{msg.is_a?(String) ? msg : msg.inspect}\n"
      end
    end

    @trace_logger = nil

    class << self
      # Default logger to use
      # @return [Logger]
      attr_reader :logger

      # Logger to use for traces
      # @return [Logger]
      attr_reader :trace_logger

      # Enable trace logging.
      #
      # @param enabled [Boolean]
      #
      # @return [void]
      def trace=(enabled)
        if enabled
          @trace_logger ||= Logger.new($stdout)
        else
          @trace_logger = nil
        end
      end

      # Returns +true+ if trace logging is enabled.
      #
      # @return [Boolean]
      def trace?
        !@trace_logger.nil?
      end

      # Silence the logger.
      #
      # @param shh [Boolean]
      #
      # @return [void]
      def silent=(shh)
        if shh
          @logger = nil
        else
          @logger ||= ::Logger.new($stdout)
          nil
        end
      end

      # Returns +true+ if the logger is nil.
      #
      # @return [Boolean]
      def silent?
        !@logger.nil?
      end

      # Returns the level of the logger.
      #
      # @return [Logger::Severity]
      def level
        @logger ? @logger.level : nil
      end

      # Sets the level of the logger.
      #
      # @param value [Logger::Severity] One of the constants in
      #   +Logger::Severity+.
      def level=(value)
        @logger = ::Logger.new($stdout) if @logger.nil?
        @logger.level = value
      end

      # Sets a custom logger.
      #
      # @param custom_logger [Logger] The custom logger to use.
      def logger=(custom_logger)
        _validate_logger!(custom_logger)
        @logger = custom_logger
      end

      # Sets the trace logger.
      #
      # @param custom_tracer [Logger] The custom trace logger to use.
      def trace_logger=(custom_tracer)
        _validate_logger!(custom_tracer)
        @trace_logger = custom_tracer
      end

      # Logs a message at a given level.
      #
      # @param msg [#to_s] Message to log
      # @param level [Logger::Severity] The severity level at which to log +msg+
      def log_msg(msg, level = ::Logger::INFO)
        return unless @logger

        @logger.add(level, msg)
      end

      # Logs a trace message.
      #
      # @param msg [#to_s] The message to log using +trace_logger+.
      def trace_msg(msg)
        return unless @trace_logger

        @trace_logger.info(msg)
      end

    private

      def _validate_logger!(custom_logger)
        %i[level level= debug info warn error fatal unknown].each do |method|
          unless custom_logger.respond_to?(method)
            raise ArgumentError, "logger must respond to #{method}"
          end
        end
      end
    end
    # end of singleton methods

    # Default logger to $stdout
    self.logger      = ::Logger.new($stdout)
    logger.level     = Logger::INFO
    logger.formatter = Logging::SimpleFormatter.new

    # Returns true if the logger is silenced.
    #
    # @return [Boolean]
    def silent
      Logging.silent?
    end

    alias silent? silent

    # Enables silencing of logger.
    #
    # @param value [Boolean]
    def silent=(value)
      Logging.silent = value
    end

    # Log a message if tracing is activated
    # @param msg [#to_s] Message to log
    def trace(msg = nil)
      Logging.trace_msg(msg) if msg
    end
    module_function :trace
    public :trace

    # Log a message at DEBUG level
    # @param msg [#to_s] Message to log
    def log_debug(msg = nil)
      Logging.log_msg(msg || yield, ::Logger::DEBUG)
    end
    module_function :log_debug
    public :log_debug

    # Log a message at INFO level
    # @param msg [#to_s] Message to log
    def log_info(msg = nil)
      Logging.log_msg(msg || yield, ::Logger::INFO)
    end
    module_function :log_info
    public :log_info

    # Log a message at ERROR level (and possibly a backtrace)
    # @param msg [#to_s] Message to log
    # @param err [StandardError] Optional error to log
    def log_error(msg, err = nil)
      log_msg = msg
      log_msg += ": #{err}\n\t#{err.backtrace.join("\n\t")}\n" if err
      Logging.log_msg(log_msg, ::Logger::ERROR)
    end
    module_function :log_error
    public :log_error
  end
end
