# frozen_string_literal: true

module VimChannels
  module Vim
    # Represents a Vim buffer, containing source text.
    class Buffer
      # Returns this buffer's `buffer number`.
      # @return [Integer]
      attr_accessor :number

      # Returns the complete buffer's string representation.
      # @return [String]
      attr_accessor :complete_buffer

      # Returns the lines of text in a buffer, including line endings.
      # @return [Array<String>]
      attr_accessor :lines

      # Returns the (vim) variables set in the buffer.
      # @return [Array<String>]
      attr_accessor :variables

      # Returns the current `shiftwidth` of the buffer.
      # @return [Integer]
      attr_accessor :shift_width
      alias shiftwidth shift_width
      alias sw shift_width

      # Returns the current `tabstop` of the buffer.
      # @return [Integer]
      attr_accessor :tab_stop
      alias tabstop tab_stop
      alias ts tab_stop

      # Initialize a new instance of {Buffer}.
      # @param number [Integer] the number of this buffer (according to vim)
      # @param options [Hash] options to create the buffer with
      # @option options [String] :complete_buffer ("") The complete text content
      #   of the buffer.
      # @option options [Array<String>] :lines ([]) The lines of the buffer.
      # @option options [Array<String>] :variables ([]) Any variables active in
      #   the buffer (from vim).
      # @option options [Integer] :shift_width (0) The current `shiftwidth` of
      #   the buffer. Also works as `:shiftwidth` or `:sw`.
      # @option options [Integer] :tab_stop (0) The current `tabstop` of the
      #   buffer. Also works as `:tabstop` or `:ts`.
      # @option options [Integer] :tabstop Alias for `:tab_stop`
      # @option options [Integer] :ts Alias for `:tab_stop`
      # @option options [Integer] :shiftwidth Alias for `:shift_width`
      # @option options [Integer] :sw Alias for `:shift_width`
      def initialize(number = 0, **options)
        @number          = number
        @complete_buffer = options.fetch(:complete_buffer, "")
        @lines           = options.fetch(:lines, [])
        @variables       = options.fetch(:variables, [])

        @shift_width = options.fetch(:shift_width) do
          options.fetch(:shiftwidth, options.fetch(:sw, 0))
        end
        @tab_stop = options.fetch(:tab_stop) do
          options.fetch(:tabstop, options.fetch(:ts, 0))
        end
      end
    end
  end
end
