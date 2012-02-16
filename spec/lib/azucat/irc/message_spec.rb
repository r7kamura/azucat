require File.expand_path("../../../spec_helper", File.dirname(__FILE__))

describe Azucat::IRC::Message do
  before { @self = Azucat::IRC::Message }

  describe ".parse" do
    context "when passed invalid string" do
      it "should raise InvalidMessage error" do
        expect { @self.parse("invalid string") }.to(
          raise_error(@self::InvalidMessage)
        )
      end
    end

    context "when passed ':foo!1.2.3.4 PRIVMSG #channel message\\r\\n'" do
      before do
        @hash = @self.parse(":foo!1.2.3.4 PRIVMSG #channel message\r\n")
      end

      describe "returned value" do
        it { @hash.should be_a Hash }
      end

      describe "[:name]" do
        it { @hash[:name].should == "foo" }
      end

      describe "[:text]" do
        it { @hash[:text].should == "#channel message" }
      end

      describe "[:tag]" do
        it { @hash[:tag].should == "PRIVMSG" }
      end
    end
  end
end
