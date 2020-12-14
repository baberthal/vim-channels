# frozen_string_literal: true

module VimChannels
  module Logging
    # Module to hold terminal codes to set colors.
    module Colors
      # Terminal code for black foreground
      BLACK_FG = "\u{001b}[0;30m"
      # Terminal code for red foreground
      RED_FG = "\u{001b}[0;31m"
      # Terminal code for green foreground
      GREEN_FG = "\u{001b}[0;32m"
      # Terminal code for yellow foreground
      YELLOW_FG = "\u{001b}[0;33m"
      # Terminal code for blue foreground
      BLUE_FG = "\u{001b}[0;34m"
      # Terminal code for magenta foreground
      MAGENTA_FG = "\u{001b}[0;35m"
      # Terminal code for cyan foreground
      CYAN_FG = "\u{001b}[0;36m"
      # Terminal code for white foreground
      WHITE_FG = "\u{001b}[0;37m"
      # Terminal code for default foreground color
      DEFAULT_FG = "\u{001b}[0;39m"

      # Terminal code for black background
      BLACK_BG = "\u{001b}[0;40m"
      # Terminal code for red background
      RED_BG = "\u{001b}[0;41m"
      # Terminal code for green background
      GREEN_BG = "\u{001b}[0;42m"
      # Terminal code for yellow background
      YELLOW_BG = "\u{001b}[0;43m"
      # Terminal code for blue background
      BLUE_BG = "\u{001b}[0;44m"
      # Terminal code for magenta background
      MAGENTA_BG = "\u{001b}[0;45m"
      # Terminal code for cyan background
      CYAN_BG = "\u{001b}[0;46m"
      # Terminal code for white background
      WHITE_BG = "\u{001b}[0;47m"
      # Terminal code for default background color
      DEFAULT_BG = "\u{001b}[0;49m"

      # Terminal code to reset foreground and background to default
      RESET = "\u{001b}[0m"

      # Terminal code to make the text bold
      BOLD = "\u{001b}[1m"
      # Terminal code to make the text underlined
      UNDERLINE = "\u{001b}[4m"
      # Terminal code to make the text reversed
      REVERSED = "\u{001b}[7m"

      # Hash that stores foregound colors, by name
      FOREGROUND_COLORS = {
        black: BLACK_FG,
        red: RED_FG,
        green: GREEN_FG,
        yellow: YELLOW_FG,
        blue: BLUE_FG,
        magenta: MAGENTA_FG,
        cyan: CYAN_FG,
        white: WHITE_FG,
        default: DEFAULT_FG
      }.freeze

      # Hash that stores background colors, by name
      BACKGROUND_COLORS = {
        black: BLACK_BG,
        red: RED_BG,
        green: GREEN_BG,
        yellow: YELLOW_BG,
        blue: BLUE_BG,
        magenta: MAGENTA_BG,
        cyan: CYAN_BG,
        white: WHITE_BG,
        default: DEFAULT_BG
      }.freeze

      # Hash that stores terminal attributes, by name
      ATTRS = {
        bold: BOLD,
        underline: UNDERLINE,
        reversed: REVERSED
      }.freeze

    module_function

      # Returns a {ColoredString} wrapper to colorize `string`.
      #
      # @param string [#to_s]
      #
      # @return [ColoredString]
      def wrap(string)
        ColoredString.new(string.to_s)
      end
      alias color wrap
      alias c wrap
      alias dye wrap
      alias paint wrap

      # Wrapper class to add colors to a string
      # @api private
      class ColoredString < String
        # Sets the foreground color of `self` to `color`.
        #
        # @param color [String, Symbol] one of the color keys
        #   in {FOREGROUND_COLORS}
        #
        # @return [ColoredString]
        def fg(color)
          color = color.to_sym
          unless FOREGROUND_COLORS.key?(color)
            raise ArgumentError, "Unknown color: #{color}"
          end

          self.class.new("#{FOREGROUND_COLORS[color]}#{self}#{RESET}")
        end

        # Sets the background color of `self` to `color`.
        #
        # @param color [String, Symbol] one of the color keys in
        #   {BACKGROUND_COLORS}
        #
        # @return [ColoredString]
        def bg(color)
          color = color.to_sym
          unless BACKGROUND_COLORS.key?(color)
            raise ArgumentError, "Unknown color: #{color}"
          end

          self.class.new("#{BACKGROUND_COLORS[color]}#{self}#{RESET}")
        end

        # Colorizes `self` with `color` as foreground and `on` as background.
        #
        # @param color [String, Symbol] foregound color for the string
        # @param on [String, Symbol] optional background color
        #
        # @return [ColoredString]
        def colorize(color, on: nil)
          color = color.to_sym
          unless FOREGROUND_COLORS.key?(color)
            raise ArgumentError, "Unknown foreground color: #{color}"
          end

          return "#{FOREGROUND_COLORS[color]}#{self}#{RESET}" if on.nil?

          on = on.to_sym
          unless BACKGROUND_COLORS.key?(on)
            raise ArgumentError, "Unknown background color: #{on}"
          end

          self.class.new(
            "#{FOREGROUND_COLORS[color]}#{BACKGROUND_COLORS[on]}#{self}#{RESET}"
          )
        end

        # Add the terminal attribute `attr` to self.
        #
        # @param attr [Symbol, String] the terminal attribute to apply
        #
        # @return [ColoredString]
        def attribute(attr)
          attr = attr.to_sym
          unless ATTRS.key?(attr)
            raise ArgumentError, "Unknown attribute: #{attr}"
          end

          self.class.new("#{ATTRS[attr]}#{self}#{RESET}")
        end
        alias attr attribute

        ## Make `self` appear bold in the terminal
        ##
        ## @return [ColoredString]
        # def bold
        #  self.class.new("#{BOLD}#{self}#{RESET}")
        # end

        ## Make `self` appear underlined in the terminal
        ##
        ## @return [ColoredString]
        # def underline
        #  self.class.new("#{UNDERLINE}#{self}#{RESET}")
        # end

        ## Make the colors of `self` reversed in the terminal
        ##
        ## @return [ColoredString]
        # def reversed
        # end

        # def respond_to_missing?(meth, include_all = false)
        #   @string.respond_to?(meth, include_all) || super
        # end

        # def method_missing(meth, *args, &block)
        #   if @string.respond_to?(meth, false)
        #     @string.send(meth, *args, &block)
        #   else
        #     super
        #   end
        # end

        FOREGROUND_COLORS.each_key do |color|
          define_method(color) { fg(color) }
        end

        BACKGROUND_COLORS.each_key do |color|
          define_method(:"on_#{color}") { bg(color) }
        end

        ATTRS.each_key do |attr|
          define_method(attr) { attribute(attr) }
        end
      end
    end
  end
end
