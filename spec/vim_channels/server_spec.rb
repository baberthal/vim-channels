# frozen_string_literal: true

class DummyBackend < VimChannels::Backends::TcpServer
  def initialize(host, port, *)
    super(host, port)
  end
end

RSpec.describe VimChannels::Server do
  let(:server) { described_class.new("0.0.0.0", 1337) }

  describe "#maximum_connections=" do
    it "sets maximum_connections size" do
      server.maximum_connections = 100
      server.config
      expect(server.maximum_connections).to eq 100
    end

    it "sets a lower maximum_connections size when too large" do
      # root users on Linux will not have a limitation on maximum connections,
      # so we can't really run this test under that condition.
      pending("Only for non-root users") if Process.euid == 0
      maximum_connections = 1_000_000
      server.maximum_connections = maximum_connections
      server.config
      expect(server.maximum_connections).to be <= maximum_connections
    end
  end

  describe "#threaded?" do
    it "defaults to false" do
      expect(server).not_to be_threaded
    end
  end

  describe "#threaded=" do
    it "sets the backend to threaded as well" do
      server.threaded = true
      expect(server.backend).to be_threaded
    end
  end

  describe "#threadpool_size=" do
    it "sets the threadpool_size" do
      server.threadpool_size = 10
      expect(server.threadpool_size).to eq 10
    end
  end

  describe "#initialize" do
    it "sets host and port" do
      server = described_class.new("192.168.1.1", 8080)

      expect(server.host).to eq "192.168.1.1"
      expect(server.port).to eq 8080
    end

    it "sets stdio" do
      server = described_class.new("stdio")
      expect(server.stdio).to be true
    end

    it "sets host, port, and app" do
      app = proc { nil }
      server = described_class.new("192.168.1.1", 8080, app)

      expect(server.host).not_to be_nil
      expect(server.app).to eq app
    end

    it "sets host, port, and backend" do
      server = described_class.new("192.168.1.1", 8080, backend: DummyBackend)

      expect(server.host).not_to be_nil
      expect(server.backend).to be_a DummyBackend
    end

    it "sets host, port, app, and backend" do
      app = proc { nil }
      server = described_class.new("192.168.1.1", 8080, app,
                                   backend: DummyBackend)

      expect(server.host).not_to be_nil
      expect(server.app).to eq app
      expect(server.backend).to be_a DummyBackend
    end

    it "can accept a string for port" do
      server = described_class.new("192.168.1.1", "8080")

      expect(server.host).to eq "192.168.1.1"
      expect(server.port).to eq 8080
    end

    it "does not register signals when signals: false" do
      server = instance_double(described_class)
      allow(described_class).to receive(:new).and_return(server)
      allow(server).to receive(:setup_signals)
      described_class.new(signals: false)
      expect(server).not_to have_received(:setup_signals)
    end
  end
end
