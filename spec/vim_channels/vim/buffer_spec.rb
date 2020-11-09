# frozen_string_literal: true

RSpec.describe VimChannels::Vim::Buffer do
  let(:buffer) { described_class.new(2, shift_width: 4, tab_stop: 8) }

  describe "#initialize" do
    context "with defaults" do
      let(:buffer) { described_class.new }

      it "initializes #number to 0" do
        expect(buffer.number).to eq 0
      end

      it "initializes #complete_buffer to an empty string" do
        expect(buffer.complete_buffer).to eq ""
      end

      it "initializes #lines to an empty array" do
        expect(buffer.lines).to eq []
      end

      it "initializes #variables to an empty array" do
        expect(buffer.variables).to eq []
      end

      it "initializes #shift_width to 0" do
        expect(buffer.shift_width).to eq 0
      end

      it "initializes #tab_stop to 0" do
        expect(buffer.tab_stop).to eq 0
      end
    end

    context "when passed only a buffer number" do
      let(:buffer) { described_class.new(2) }

      it "uses the passed in buffer number" do
        expect(buffer.number).to eq 2
      end
    end

    context "when passed a number and options hash" do
      let(:bufopts) do
        {
          complete_buffer: "this is the whole buffer\n",
          lines: ["this is the whole buffer\n"],
          variables: [],
          sw: 2,
          ts: 8
        }
      end
      let(:buffer) { described_class.new(2, **bufopts) }

      it "uses the passed in buffer number" do
        expect(buffer.number).to eq 2
      end

      it "uses the supplied value for #complete_buffer" do
        expect(buffer.complete_buffer).to eq "this is the whole buffer\n"
      end

      it "uses the supplied value for #lines" do
        expect(buffer.lines).to eq ["this is the whole buffer\n"]
      end

      it "uses the supplied value for #variables" do
        expect(buffer.variables).to eq []
      end

      it "uses the supplied value for #shift_width" do
        expect(buffer.shift_width).to eq 2
      end

      it "uses the supplied value for #tab_stop" do
        expect(buffer.tab_stop).to eq 8
      end
    end
  end

  describe "#shift_width" do
    it "returns the supplied value" do
      expect(buffer.shift_width).to eq 4
    end

    it "also works as #shiftwidth" do
      expect(buffer.shiftwidth).to eq 4
    end

    it "also works as #sw" do
      expect(buffer.sw).to eq 4
    end
  end

  describe "#tab_stop" do
    it "returns the supplied value" do
      expect(buffer.tab_stop).to eq 8
    end

    it "also works as #tabstop" do
      expect(buffer.tabstop).to eq 8
    end

    it "also works as #ts" do
      expect(buffer.ts).to eq 8
    end
  end
end
