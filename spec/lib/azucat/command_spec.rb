require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Azucat::Command do
  before do
    @self = Azucat::Command
  end

  describe "#register and #input" do
    before do
      Azucat::Command.stub(:output)
    end

    it "register command and respond only to matched input" do
      flag = false
      @self.register(/foo/) { flag = true }

      @self.input("bar")
      flag.should be_false

      @self.input("foo")
      flag.should be_true
    end
  end

  describe "commands" do
    before do
      Azucat::Command.stub(:output)
    end

    it "tweet" do
      Azucat::Twitter.should_receive(:tweet) do |args|
        args.should == "foo"
      end
      Azucat::Command.input("tweet foo")
    end
  end
end
