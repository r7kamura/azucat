require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Azucat::IRC do
  before do
    @self = Azucat::IRC
  end

  describe ".run" do
    context "when config.irc is false" do
      before do
        Azucat.config.irc = false
      end
      it "do nothing" do
        @self::Client.should_not_receive(:new)
        @self.run
      end
    end

    context "when config.irc is configured" do
      before do
        Azucat.config.irc = {
          :server   => "irc.freenode.net",
          :port     => 6667,
          :channel  => "#azucat",
          :username => "azucat"
        }
        Azucat::Output.stub(:error)
        @self.client.stub(:start)
      end
      it "create and start Azucat::IRC::Client" do
        begin
          @self::Client.new(Azucat.config.irc)
          @self.client.should_receive(:start)
          @self.run
        rescue SocketError
          pending "can't connect to server"
        end
      end
    end
  end
end
