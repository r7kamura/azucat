require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Azucat::Command do
  before do
    @self = Azucat::Command
  end

  describe "#register and #input" do
    it do
      @self.should be_respond_to :register
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
end
