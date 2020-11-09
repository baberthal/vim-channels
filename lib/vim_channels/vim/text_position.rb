# frozen_string_literal: true

module VimChannels
  module Vim
    # Represents a position in a {Vim::Buffer}.
    class TextPosition
      # The column in the source code. Note that this is a 1-based index.
      # @return [Integer]
      attr_accessor :column

      # The line in the source code. Note that this is a 1-based index.
      # @return [Integer]
      attr_accessor :line

      # @overload initialize(column, line)
      #   @param column [Integer] The column in the source code
      #   @param line [Integer] The line in the source code
      #
      # @overload initialize(pair)
      #   @param pair [Array(Integer, Integer)] A column, line pair to denote
      #     the position in the source code.
      #
      # @overload initialize()
      #   Returns a default-initialized (i.e. (1,1)) position in the source
      #   code.
      def initialize(*args)
        case args.length
        when 0 then _init(1, 1)
        when 1
          unless args.first.is_a?(Array) && args.first.length == 2
            raise ArgumentError, "Must pass a 2-element array"
          end

          _init(*args.first)

        when 2 then _init(*args)
        else raise ArgumentError, "Invalid arguments passed to constructor"
        end
      end

      def hash
        column.hash ^ line.hash
      end

      def ==(other)
        other_col, other_line = if other.is_a?(TextPosition)
          [other.column, other.line]
        elsif other.is_a?(Array) && other.length == 2
          other
        end

        column == other_col && line == other_line
      end

    private

      def _init(column, line)
        @column = Integer(column)
        @line   = Integer(line)
      end
    end
  end
end
