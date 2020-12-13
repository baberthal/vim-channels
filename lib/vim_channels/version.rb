# frozen_string_literal: true

module VimChannels
  # Module to store version information.
  module VERSION
    MAJOR = 0
    MINOR = 1
    PATCH = 0

    STRING = [MAJOR, MINOR, PATCH].join(".")
  end

  NAME = "vim-channels"
  SERVER = "#{NAME} #{VERSION::STRING}"
end
