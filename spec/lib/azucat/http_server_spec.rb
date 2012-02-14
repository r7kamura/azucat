require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Azucat::HTTPServer do
  before do
    @self = Azucat::HTTPServer
  end

  describe ".open_browser" do
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

    context "when Azucat.config.open_browser is false" do
      before { Azucat.config.open_browser = false }
      after  { Azucat.config.open_browser = true  }
      it "do nothing" do
        ::Launchy.should_not_receive(:open)
        @self.send(:open_browser)
      end
    end
  end

  describe ".run" do
    it "launch HTTP server and open browser" do
      @self.should_receive(:open_browser) { raise SystemExit }
      expect { @self.run }.to raise_error SystemExit
    end
  end

  describe "Sinatra::Base" do
    include Rack::Test::Methods
    def app
      Azucat::HTTPServer::App
    end

    describe "GET /" do
      before  { get "/" }
      subject { last_response }
      it { should be_ok }
      it "should include configured WebSocket port" do
        should match(Azucat.config.ws_port.to_s)
      end
    end

    describe "GET /favicon.ico" do
      before  { get "/favicon.ico" }
      subject { last_response }
      it { should be_ok }
    end

    describe "POST /" do
      before { Azucat::Command.stub(:input) }

      describe "access" do
        before  { post "/" }
        subject { last_response }
        it { should be_ok }
      end

      context "when passed params[:command]" do
        it "should pass it to Command.input" do
          input = "foo"
          Azucat::Command.should_receive(:input).with(input)
          post "/", :command => input
        end
      end

      context "when not passed params[:command]" do
        it "should do nothing" do
          Azucat::Command.should_not_receive(:input)
          post "/"
        end
      end
    end
  end
end
