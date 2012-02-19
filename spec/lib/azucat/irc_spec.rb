require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Azucat::IRC do
  before do
    @self = Azucat::IRC
  end

  describe ".run" do
    context "when config.irc is false" do
      before do
        Azucat.config.irc = false
        @runs = Azucat.instance_variable_get(:@runs)
        Azucat.instance_variable_set(:@runs, [])
      end
      after do
        Azucat.instance_variable_set(:@runs, @runs)
      end

      it "do nothing" do
        @self.should_not_receive(:setup_client)
        Azucat.run { Azucat.stop }
        Azucat.run
      end
    end

    context "when config.irc is passed" do
      before do
        Azucat.config
      end
    end
  end
end
