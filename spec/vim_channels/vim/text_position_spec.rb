# frozen_string_literal: true

RSpec.describe VimChannels::Vim::TextPosition do
  describe "#initialize" do
    context "when passed no arguments" do
      let(:tp) { described_class.new }

      it "initializes with column=1" do
        expect(tp.column).to eq 1
      end

      it "initializes with line=1" do
        expect(tp.line).to eq 1
      end
    end

    context "when passed two arguments" do
      let(:tp) { described_class.new(3, 47) }

      it "initializes with the passed column" do
        expect(tp.column).to eq 3
      end

      it "initializes with the passed line" do
        expect(tp.line).to eq 47
      end
    end

    context "when passed a 2-element array containing line and column" do
      let(:tp) { described_class.new([2, 42]) }

      it "initializes with the first element as column" do
        expect(tp.column).to eq 2
      end

      it "initializes with the second element as line" do
        expect(tp.line).to eq 42
      end
    end

    context "when passed any other arguments" do
      it "throws ArgumentError when passed 3 arguments" do
        expect { described_class.new(1, 2, 3) }.to raise_error ArgumentError
      end

      it "throws ArgumentError when passed an array with more than 2 elements" do
        expect { described_class.new([1, 2, 3]) }.to raise_error ArgumentError
      end

      it "throws ArgumentError when passed only one non-array argument" do
        expect { described_class.new(1) }.to raise_error ArgumentError
      end
    end

    context "when passed strings that represent integers" do
      let(:tp) { described_class.new("1", "2") }

      it "converts :column to an integer" do
        expect(tp.column).to eq 1
      end

      it "converts :line to an Integer" do
        expect(tp.line).to eq 2
      end
    end
  end

  describe "#==" do
    let(:tp1) { described_class.new(2, 42) }
    let(:tp2) { described_class.new(2, 42) }
    let(:tp3) { described_class.new(5, 37) }

    it "returns true when line and column are equal" do
      expect(tp1 == tp2).to be true
    end

    it "returns false when line and column do not equal" do
      expect(tp1 == tp3).to be false
    end

    it "can compare with an array" do
      expect(tp1 == [2, 42]).to be true
    end
  end
end
