require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Azucat::HTTPServer do
  before do
    @self = Azucat::HTTPServer
  end

  describe "#open_browser" do
    context "normally" do
      before do
        Azucat.send(:configure)
        @port = Azucat.config.http_port
        @host = Azucat.config.http_host
        ::Launchy.should_receive(:open) { |url| url }
      end
      it "open browser with its host and port" do
        url = "http://#{@host}:#{@port}"
        @self.send(:open_browser).should == url
      end
    end

    context "when Launchy does not work fine" do
      before do
        ::Launchy.stub(:open) { raise }
      end
      it "do nothing and return nil" do
        expect { @self.send(:open_browser) }.not_to raise_error
      end
    end
  end

  describe "#run" do
    it "launch HTTP server and open browser" do
      @self.should_receive(:open_browser) { raise SystemExit }
      expect { @self.run }.to raise_error SystemExit
    end
  end
end
