# frozen_string_literal: true

module VimChannels
  # Module to store version information.
  module VERSION
    # Major version of VimChannels.
    MAJOR = 0
    # Minor version of VimChannels.
    MINOR = 1
    # Patch version of VimChannels.
    PATCH = 0

    # String describing the version number of VimChannels.
    STRING = [MAJOR, MINOR, PATCH].join(".")
  end

  # Name of the library.
  NAME = "vim-channels"

  # Descriptive name of the server.
  SERVER = "#{NAME} #{VERSION::STRING}"
end
