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
  end
end
