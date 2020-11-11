# frozen_string_literal: true

module VimChannels
  # Represents a message either sent to or received from vim over a channel.
  class Message
    # ID of this message.
    # If this is a positive number, it came **from** vim.
    # If this is a negative number, the message originated from the server.
    #
    # @return [Integer]
    attr_accessor :id

    # Body of the message. Typically either an Array or a Hash.
    #
    # @return [Array, Hash]
    attr_accessor :payload
    alias body= payload=
    alias body payload

    # Parse a message from a JSON string.
    #
    # @param json [String] JSON string containing the message data
    #
    # @return [VimChannels::Message, nil] The resulting message, or nil if the
    #   data was malformed.
    def self.parse(json)
      parsed = JSON.parse(json)
      return nil unless parsed[0].is_a?(Integer)

      new(*parsed)
    end

    # Parse a message from a JSON string, and raise an error if the message is
    # invalid.
    #
    # (see .parse)
    def self.parse!(json)
      parsed = parse(json)
      return parsed unless parsed.nil?

      raise ArgumentError, "Invalid json: #{json}"
    end

    # Creates a new Message object.
    #
    # @overload initialize(id)
    #   Initialize a message without a payload.
    #   @param id [Integer] The id of the message
    #
    # @overload initialize(payload)
    #   Initialize a message without an id.
    #   @param payload [#to_json] A json-representable object that contains the
    #     message's payload.
    #
    # @overload initialize(id, payload)
    #   Initialize a message with both an id and payload.
    #   @param id [Integer] The ID of the message. Can be nil.
    #   @param payload [#to_json] A json-representable object that contains the
    #     message's payload.
    #
    # @overload initialize()
    #   Initialize a message with id of 0 and no payload.
    def initialize(id_or_payload = nil, payload = nil)
      @id, @payload = if id_or_payload.nil?
        [0, nil]
      elsif id_or_payload.is_a?(Integer)
        [id_or_payload, payload]
      else
        [0, id_or_payload]
      end
    end

    # Returns a representation of the message, suitable for JSON serialization.
    #
    # @return [Array(Integer, Array)]
    def as_json(*)
      [id, payload]
    end

    # Returns a representation of the message, serialized in JSON format.
    #
    # @return [String]
    def to_json(*args)
      as_json(*args).to_json
    end

    # Resets the message to its initial state.
    #
    # @return [void]
    def reset!
      @id = 0
      @payload = nil
    end

    # Updates a message from parsed json.
    #
    # @param json [Array(Integer, Object)] The parsed json object.
    #
    # @return [void]
    def update(json)
      @id = json[0]
      @payload = json[1]
    end

    # Returns a string representation of the Message object.
    #
    # @return [String]
    def to_s
      "[#{id}, #{(payload || '').to_json}]"
    end

    # Returns a string representation of the Message object.
    #
    # @return [String]
    def inspect
      "#<#{self.class}: id=#{id}, payload=#{payload.inspect}>"
    end
  end
end
