require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Azucat::Command do
  before do
    @self = Azucat::Command
    Azucat::Output.stub(:puts)
  end

  describe "#register and #input" do
    it "register command and respond to only matched input" do
      flag = false
      @self.register(/foo/) { flag = true }
      @self.input("bar"); flag.should be_false
      @self.input("foo"); flag.should be_true
    end
  end

  describe "commands" do
    describe "> " do
      it "eval input" do
        @self.should_receive(:eval)
        @self.input("> true")
      end

      it "output error when raised" do
        Azucat::Output.should_receive(:error)
        @self.input("> foo")
      end
    end
  end
end
