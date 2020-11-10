# frozen_string_literal: true

require "json"

module VimChannels
  module Vim
    # With a JSON channel the process can send commands to Vim that will be
    # handled by Vim internally, it does not require a handler for the channel.
    #
    # Possible commands are:
    #
    # - {.redraw}: redraw the screen
    # - {.ex}: an ex command
    # - {.normal}: a normal-mode command
    # - {.expr}: an expression, with an optional response requested
    # - {.call}: call a Vim function, with an argument list, and an optional
    #   response
    #
    # With all of these: Be careful what these commands do!  You can easily
    # interfere with what the user is doing.  To avoid trouble use `mode()` to
    # check that the editor is in the expected state.  E.g., to send keys that
    # must be inserted as text, not executed as a command:
    #   ["ex","if mode() == 'i' | call feedkeys('ClassName') | endif"]
    #
    # @example Send keys that must be inserted as text, not executed
    #   ["ex","if mode() == 'i' | call feedkeys('ClassName') | endif"]
    #
    # Errors in these commands are normally not reported to avoid them messing
    # up the display.  If you do want to see them, set the 'verbose' option (in
    # Vim) to 3 or higher.
    #
    # If you decide to subclass this command and implement another vim command,
    # make sure to override thie following methods:
    #
    # * {#initialize} - to initialize an instance of the command subclass.
    # * {#as_json}    - to return a representation of the instance suitable
    #   for json serialization. This is typically an Array or a Hash.
    #
    # Additionally, you should add a class method to {Command} to create
    # instances of your class. They should never be instantiated directly.
    class Command
      # Subclasses must implement {#as_json} to return a representation of the
      # instance suitable for JSON serialization.
      #
      # @return [Array, Hash]
      def as_json(*)
        raise NotImplementedError
      end

      # Returns a JSON representation of the Command.
      #
      # @return [String]
      def to_json(*args)
        as_json(*args).to_json
      end

      # Returns a string representation of the Command. Subclasses can override
      # this method to return a better string representation. The default
      # implementation simply returns {#to_json}.
      #
      # @return [String]
      def to_s
        to_json
      end

      # Returns a string representation of the Command. Subclasses can override
      # this method to return a better representation. The default
      # implementation simply returns {#to_s}.
      #
      # @return [String]
      def inspect
        to_s
      end

      # Create a {Redraw} command.
      #
      # The other commands do not update the screen, so that you can send
      # a sequence of commands without the cursor moving around.  You must end
      # with the "redraw" command to show any changed text and show the cursor
      # where it belongs.
      #
      # @param force [Boolean] Pass `true` to force the redraw in vim.
      #
      # @return [Command::Redraw] The redraw command.
      def self.redraw(force: false)
        Redraw.new(force)
      end

      # Create an {Ex} command.
      #
      # The "ex" command is executed as any Ex command.  There is no response
      # for completion or error. You could use functions in an autoload script:
      #
      # @example call a function in an autoload script
      #   Vim::Command.ex("call myscript#MyFunc(arg)")
      #
      # You can also use "call feedkeys()" to insert any key sequence.
      #
      # When there is an error a message is written to the channel log, if it
      # exists, and v:errmsg is set to the error.
      #
      # @param command [String] The ex command to execute.
      #
      # @return [Command::Ex] The ex command.
      def self.ex(command)
        Ex.new(command)
      end

      # Create a normal-mode command.
      #
      # The "normal" command is executed like with ":normal!", commands are not
      # mapped.
      #
      # @example Open the folds under the cursor
      #   Vim::Command.normal("zO")
      #
      # @param command [String] The normal mode command to execute.
      #
      # @return [Command::Normal] The normal mode command.
      def self.normal(command)
        Normal.new(command)
      end

      # Create an expression command.
      #
      # The "expr" command can be used to get the result of an expression. For
      # example, to get the number of lines in the current buffer:
      #
      #     Vim::Command.expr("line('$')", -2)
      #
      # It will send back the result of the expression:
      #
      #     [-2, "last line"]
      #
      # The format is:
      #
      #     [`number`, `result`]
      #
      # Here `number` is the same as what was in the request. Use a negative
      # number to avoid confusion with message that Vim sends. Use a different
      # number on every request to be able to match the request with the
      # response.
      #
      # `result` is the result of the evaluation and is JSON encoded.  If the
      # evaluation fails or the result can't be encoded in JSON it is the string
      # "ERROR".
      #
      # Command "expr" without a response:
      #
      # This command is similar to "expr" above, but does not send back any
      # response.
      #
      # @example expr with no response
      #   Vim::Command.expr("setline('$', ['one', 'two', 'three'])")
      #
      # There is no second argument in the request.
      #
      # @param expression [String] The expression to evaluate.
      # @param id [Integer] An optional id for the expression. If this is set,
      #                     vim will send a response to the server with the
      #                     result of the expression.
      #
      # @return [Command::Expr] The expression.
      def self.expr(expression, id: nil)
        Expr.new(expression, id: id)
      end

      # Create a function call command.
      #
      # This is similar to "expr", but instead of passing the whole expression
      # as a string this passes the name of a function and a list of arguments.
      # This avoids the conversion of the arguments to a string and escaping and
      # concatenating them.
      #
      # @example
      #   Vim::Command.call("line", ["$"], -2)
      #
      # Leave out the third argument if no response is to be sent:
      # @example without a response
      #   Vim::Command.call("setline", ["$", ["one", "two", "three"]])
      #
      # @param function [String] The name of the function to call in vim
      # @param args [Array<String>] An array of arguments to pass to the
      #                                     vim function.
      # @param id [Integer] An optional id. If this is set, vim will send
      #                     a response to the server.
      #
      # @return [Command::Call] A `Call` command.
      def self.call(function, args, id: nil)
        Call.new(function, args, id: id)
      end

      # Representation of a `redraw` command.
      class Redraw < Command
        # @api private
        # @private
        def initialize(force)
          @force = force
        end

        # (see Command#as_json)
        def as_json(*)
          ["redraw", @force ? "force" : ""]
        end
      end

      # Representation of an `ex` command.
      class Ex < Command
        # @api private
        # @private
        def initialize(command)
          @command = command.to_s
        end

        # (see Command#as_json)
        def as_json(*)
          ["ex", @command]
        end
      end

      # Representation of a `normal` mode command.
      class Normal < Command
        # @api private
        # @private
        def initialize(command)
          @command = command.to_s
        end

        # (see Command#as_json)
        def as_json(*)
          ["normal", @command]
        end
      end

      # Representation of an `expr` command.
      class Expr < Command
        # @api private
        # @private
        def initialize(expression, id: nil)
          @expression = expression.to_s
          @id = id
        end

        # (see Command#as_json)
        def as_json(*)
          if id = @id
            ["expr", @expression, id]
          else
            ["expr", @expression]
          end
        end
      end

      # Representation of a `call` command.
      class Call < Command
        # @api private
        # @private
        def initialize(function, args, id: nil)
          @function = function.to_s
          @args = args
          @id = id
        end

        # (see Command#as_json)
        def as_json(*)
          if id = @id
            ["call", @function, @args, id]
          else
            ["call", @function, @args]
          end
        end
      end
    end
  end
end
