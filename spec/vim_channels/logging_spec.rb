# frozen_string_literal: true

# Dummy class to mix-in the Logging module for testing.
class TestLogging
  include VimChannels::Logging
end

RSpec.describe VimChannels::Logging do
  subject(:obj) { TestLogging.new }

  after do
    described_class.silent = true
    described_class.level  = Logger::INFO
    described_class.trace  = false
  end

  describe "setting a custom logger" do
    it "does not accept a logger that does not conform to the protocol" do
      expect { described_class.logger = "" }.to raise_error ArgumentError
    end

    it "accepts a custom logger that conforms to the protocol" do
      expect { described_class.logger = Logger.new($stdout) }.not_to raise_error
    end
  end

  describe "logging with a custom logger" do
    before do
      @readpipe, @writepipe = IO.pipe
      @custom_logger = Logger.new(@writepipe)
      described_class.logger = @custom_logger
      described_class.level  = Logger::INFO
    end

    after do
      [@readpipe, @writepipe].each do |pipe|
        pipe&.close
      end
    end

    it "outputs debug logs at log level DEBUG" do
      described_class.level = Logger::DEBUG
      obj.log_debug("hi")

      str = nil
      expect { str = @readpipe.read_nonblock(512) }.not_to raise_error
      expect(str).not_to be_nil
    end

    it "does not output debug logs if log level is not DEBUG" do
      described_class.level = Logger::INFO
      obj.log_debug("hello")
      expect { @readpipe.read_nonblock(512) }.to \
        raise_error IO::EAGAINWaitReadable
    end

    it "is usable at the module level for logging" do
      allow(@custom_logger).to receive(:add)
      described_class.log_msg("hey")
      expect(@custom_logger).to have_received(:add).with(Logger::INFO, "hey")
    end

    it "does not log messages if the module has been silenced" do
      described_class.silent = true
      obj.log_info("hola")
      expect { @readpipe.read_nonblock(512) }.to \
        raise_error IO::EAGAINWaitReadable
    end

    it "does not log anything if the module has been silenced" do
      described_class.silent = true
      described_class.log_msg("hi there")
      expect { @readpipe.read_nonblock(512) }.to \
        raise_error IO::EAGAINWaitReadable
    end

    it "does not log messages if logging has been silenced via instance meths" do
      obj.silent = true
      obj.log_info("hi friend")
      expect { @readpipe.read_nonblock(512) }.to \
        raise_error IO::EAGAINWaitReadable
    end
  end

  describe "logging with the default logger" do
    it "logs at debug level if debug logging is enabled" do
      described_class.level = Logger::DEBUG
      out = with_redirected_stdout { obj.log_debug("HEY!") }

      expect(out).to include "HEY!"
      expect(out).to include "DEBUG"
    end

    it "is usable at the module level for logging" do
      out = with_redirected_stdout { described_class.log_msg("HEY!") }
      expect(out).to include "HEY!"
    end
  end

  describe "tracing with a custom logger" do
    before do
      @custom_tracer = Logger.new($stderr)
      described_class.trace_logger = @custom_tracer
      allow(@custom_tracer).to receive(:info).and_call_original
    end

    it "does not emit trace messages if tracing is disabled" do
      described_class.trace = false
      obj.trace("woah there!")
      expect(@custom_tracer).not_to have_received(:info)
    end

    it "emits trace messages when tracing is enabled" do
      described_class.trace = true
      obj.trace("aloha ohana")
      expect(@custom_tracer).to have_received(:info).with(1, "aloha ohana")
    end
  end

  describe "tracing with the default logger" do
    it "emits trace messages if tracing is enabled" do
      described_class.trace = true
      out = with_redirected_stdout do
        obj.trace("Hey")
      end
      expect(out).to include "Hey"
    end

    it "is usable at the module level for logging" do
      described_class.trace = true
      out = with_redirected_stdout do
        described_class.trace_msg("hey")
      end
      expect(out).to include "hey"
    end
  end
end
