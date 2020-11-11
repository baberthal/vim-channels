# frozen_string_literal: true

RSpec.describe VimChannels::Vim::Command do
  describe ".redraw" do
    it "with no arguments, returns ['redraw', '']" do
      expect(described_class.redraw).to eq ["redraw", ""]
    end

    it "returns ['redraw', 'force'] if force: true" do
      expect(described_class.redraw(force: true)).to eq %w[redraw force]
    end
  end

  describe ".ex" do
    it "returns an array with 'ex' as the 1st element, and the command 2nd" do
      cmd = "if mode() == 'i' | call feedkeys('ClassName') | endif"
      expect(described_class.ex(cmd)).to eq ["ex", cmd]
    end
  end

  describe ".normal" do
    it "returns an array with 'normal' as the 1st element, and the cmd 2nd" do
      expect(described_class.normal("zO")).to eq %w[normal zO]
    end
  end

  describe ".expr" do
    context "when a result is expected and an ID is passed" do
      it "returns an array with 'expr', the expression, and the id" do
        expect(described_class.expr("line('$')", -2)).to \
          eq ["expr", "line('$')", -2]
      end
    end

    context "when no response is expected and no id is passed" do
      it "returns an array with 'expr' and the expression" do
        expect(described_class.expr("setline('$'), ['one', 'two', 'three']"))
          .to eq ["expr", "setline('$'), ['one', 'two', 'three']"]
      end
    end
  end

  describe ".call" do
    context "when a response is expected and an id is passed" do
      it "returns an array with 'call', the func name, args, and an id" do
        expect(described_class.call("line", ["$"], -2))
          .to eq ["call", "line", ["$"], -2]
      end
    end

    context "when response is expected and no id is passed" do
      it "returns an array with 'call', the func name, and arguments" do
        expect(described_class.call("setline", ["$", %w[one two three]]))
          .to eq ["call", "setline", ["$", %w[one two three]]]
      end
    end
  end
end
