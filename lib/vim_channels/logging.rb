# frozen_string_literal: true

require "vim_channels/logging/colors"
require "vim_channels/logging/logger"
require "forwardable"

module VimChannels
  # Module to hold logging abstractions.
  module Logging
    class << self
      extend Forwardable

      attr_writer :logger

      def logger
        @logger ||= default_logger
      end

      def default_logger
        VimChannels::Logging::Logger.new($stdout)
      end

      def_delegators :logger, :add, :debug, :error, :fatal, :info, :log
      def_delegators :default_logger, :unknown, :warn
    end

    def logger
      Logging.logger
    end

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
