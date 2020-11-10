# frozen_string_literal: true

RSpec.describe VimChannels::Vim::Command do
  describe ".redraw" do
    it "returns a Redraw command" do
      expect(described_class.redraw).to be_a VimChannels::Vim::Command::Redraw
    end
  end

  describe ".ex" do
    it "returns an Ex command" do
      expect(described_class.ex("cmd")).to be_a VimChannels::Vim::Command::Ex
    end
  end

  describe ".normal" do
    it "returns a Normal command" do
      expect(described_class.normal("gg")).to \
        be_a VimChannels::Vim::Command::Normal
    end
  end

  describe ".expr" do
    it "returns an Expr command" do
      expect(described_class.expr("&sw")).to be_a VimChannels::Vim::Command::Expr
    end
  end

  describe ".call" do
    it "returns a Call command" do
      expect(described_class.call("fn", ["args"])).to \
        be_a VimChannels::Vim::Command::Call
    end
  end
end
