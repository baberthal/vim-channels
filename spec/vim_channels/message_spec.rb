# frozen_string_literal: true

RSpec.describe VimChannels::Message do
  let(:msg) { described_class.new(-4, "some payload") }

  describe ".parse" do
    let(:json) { '[-7, "message payload"]' }
    let(:msg) { described_class.parse(json) }

    it "properly parses the id" do
      expect(msg.id).to eq(-7)
    end

    it "properly parses the payload" do
      expect(msg.payload).to eq "message payload"
    end
  end

  describe ".parse!" do
    let(:msg) { described_class.parse!(json) }

    context "with a valid json string" do
      let(:json) { '[-7, "message payload"]' }

      it "properly parses the id" do
        expect(msg.id).to eq(-7)
      end

      it "properly parses the payload" do
        expect(msg.payload).to eq("message payload")
      end
    end

    context "with an invalid json string" do
      let(:json) { '[-3.54, "message payload"]' }

      it "raises an ArgumentError" do
        expect { msg }.to raise_error ArgumentError, /Invalid json/
      end
    end
  end

  describe "#initialize" do
    context "when passed no arguments" do
      let(:msg) { described_class.new }

      it "initializes id to 0" do
        expect(msg.id).to be 0
      end

      it "initializess payload to nil" do
        expect(msg.payload).to be nil
      end
    end

    context "when passed only an id" do
      let(:msg) { described_class.new(-1) }

      it "initializes with the given id" do
        expect(msg.id).to be(-1)
      end

      it "initializes payload to nil" do
        expect(msg.payload).to be nil
      end
    end

    context "when passed both an id and payload" do
      let(:msg) { described_class.new(-2, "message payload") }

      it "initializes with the given id" do
        expect(msg.id).to be(-2)
      end

      it "initializes payload to nil" do
        expect(msg.payload).to be "message payload"
      end
    end

    context "when passed only a payload" do
      let(:msg) { described_class.new("message payload") }

      it "initializes id to 0" do
        expect(msg.id).to be 0
      end

      it "initializes with the given payload" do
        expect(msg.payload).to be "message payload"
      end
    end
  end

  describe "#as_json" do
    it "returns an array" do
      expect(msg.as_json).to be_an Array
    end

    it "returns an array containing the id and payload" do
      expect(msg.as_json).to eq [-4, "some payload"]
    end
  end

  describe "#to_json" do
    before { allow(msg).to receive(:as_json).and_call_original }

    it "calls #as_json" do
      msg.to_json
      expect(msg).to have_received(:as_json)
    end

    it "returns a string" do
      expect(msg.to_json).to be_a String
    end

    it "returns a json-serialized string of the message" do
      expect(msg.to_json).to eq '[-4,"some payload"]'
    end
  end

  describe "#reset!" do
    before { msg.reset! }

    it "resets the message id" do
      expect(msg.id).to be 0
    end

    it "resets the message payload" do
      expect(msg.payload).to be nil
    end
  end

  describe "#update" do
    let!(:msg) { described_class.new(-4, "some payload") }

    it "updates the id" do
      msg.update([-5, "another payload"])
      expect(msg.id).to eq(-5)
    end

    it "updates the payload" do
      msg.update([-5, "another payload"])
      expect(msg.payload).to eq "another payload"
    end
  end

  describe "#to_s" do
    context "when the message has no body" do
      let(:msg) { described_class.new(-7) }

      it "returns a string representation of the message" do
        expect(msg.to_s).to eq '[-7, ""]'
      end
    end

    context "when the message has a body" do
      let(:msg) { described_class.new(-8, "foo bar baz") }

      it "returns a string representation of the message" do
        expect(msg.to_s).to eq '[-8, "foo bar baz"]'
      end
    end
  end

  describe "#inspect" do
    it "returns a prettier representation of the string" do
      expect(msg.inspect).to \
        eq '#<VimChannels::Message: id=-4, payload="some payload">'
    end
  end
end
