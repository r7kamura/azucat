require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Azucat::Command do
  before do
    @self = Azucat::Command
    Azucat::Output.stub(:puts)
  end

  describe ".register and .input" do
    it "register command and respond to only matched input" do
      flag = false
      @self.register(/foo/) { flag = true }
      @self.input("bar"); flag.should be_false
      @self.input("foo"); flag.should be_true
    end
  end

  describe "commands" do
    describe "ruby" do
      it "eval input" do
        @self.should_receive(:eval)
        @self.input("ruby true")
      end

      it "output error when raised" do
        Azucat::Output.should_receive(:error)
        @self.input("ruby foo")
      end
    end

    describe "help" do
      it "should show information about commands" do
        Azucat::Output.should_receive(:puts).at_least(3).times
        @self.input("help")
      end

      describe ".pretty_help" do
        subject { @self.send(:pretty_help).join }

        describe "about command help" do
          it { should match(/help - show help about commands/) }
        end

        describe "about command ruby" do
          it { should match(/ruby <param> - eval <param> as Ruby command/) }
        end

        describe "about command >" do
          it { should match(/> <param> - eval <param> as Shell command/) }
        end
      end
    end
  end
end
