# frozen_string_literal: true

require "json"
require "concurrent"
require "forwardable"
require "eventmachine"

# Main VimChannels module.
module VimChannels
  autoload :Connection, "vim_channels/connection"
  autoload :Logging,    "vim_channels/logging"
  autoload :Message,    "vim_channels/message"
  autoload :Server,     "vim_channels/server"

  # Module that holds Backend implementations.
  module Backends
    autoload :Base,        "vim_channels/backends/base"
    autoload :StdioServer, "vim_channels/backends/stdio_server"
    autoload :TcpServer,   "vim_channels/backends/tcp_server"
  end

  # Module that holds vim support classes and methods.
  module Vim
    autoload :Buffer,       "vim_channels/vim/buffer"
    autoload :Command,      "vim_channels/vim/command"
    autoload :TextPosition, "vim_channels/vim/text_position"
  end

  # Base error class
  class Error < StandardError; end

  # Error raised when a response times out.
  class ResponseTimeoutError < Error; end

  # Error raised when a response is aborted.
  class ResponseAbortedError < Error; end

  # Error raised when a response fails.
  class ResponseFailedError < Error; end

  # Returns +true+ if VimChannels is running on a Windows platform.
  #
  # @return [Boolean]
  def self.win?
    /mswin|mingw/.match?(RUBY_PLATFORM)
  end

  # Returns +true+ if VimChannels is running on a Linux platform.
  #
  # @return [Boolean]
  def self.linux?
    /linux/.match?(RUBY_PLATFORM)
  end
end

require "vim_channels/version"
