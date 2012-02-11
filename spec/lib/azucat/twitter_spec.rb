require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Azucat::Twitter do
  before do
    @self = Azucat::Twitter
    Azucat.send(:configure, :twitter => true)
    Azucat.send(:init)
  end

  describe "#recent" do
    it "return recent tweets" do
      Azucat::Output.should_receive(:puts).at_least(:once)
      @self.recent
    end
  end
end
