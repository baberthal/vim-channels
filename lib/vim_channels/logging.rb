# frozen_string_literal: true

require "vim_channels/logging/colors"
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

      def trace=(enabled)
        @trace_logger = (Logger.new($stdout) if enabled)
      end

      def trace?
        !@trace_logger.nil?
      end

      def silent=(shh)
        if shh
          @logger = nil
        else
          @logger ||= ::Logger.new($stdout)
        end
      end

      def silent?
        !@logger.nil?
      end

      def level
        @logger ? @logger.level : nil
      end

      def level=(value)
        @logger = ::Logger.new($stdout) if @logger.nil?
        @logger.level = value
      end

      def logger=(custom_logger)
        _validate_logger!(custom_logger)
        @logger = custom_logger
      end

      def trace_logger=(custom_tracer)
        _validate_logger!(custom_tracer)
        @trace_logger = custom_tracer
      end

      def log_msg(msg, level = ::Logger::INFO)
        return unless @logger

        @logger.add(level, msg)
      end

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

    def silent
      Logging.silent?
    end

    alias silent? silent

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

    # Simple singleton class to use as a shared logger.
    class Log
      def self.unknown(*); end
      def self.fatal(*); end
      def self.error(*); end
      def self.warn(*); end
      def self.info(*); end
      def self.debug(*); end
      def self.log(*); end
    end
  end
end
