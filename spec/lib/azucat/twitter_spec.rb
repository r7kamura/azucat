require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Azucat::Twitter do
  before do
    @self = Azucat::Twitter

    Azucat.send(:configure, :twitter => true)
    pending("no twitter access key given") unless Azucat.config.access_key

    Azucat.send(:init)
    pending("can not access to the Internet") unless Azucat.config.twitter
  end

  describe ".recent" do
    it "return recent tweets" do
      Azucat::Output.should_receive(:puts).at_least(:once)
      @self.recent
    end
  end

  describe ".setup_config" do
    context "when no twitter access key exists" do
      before do
        @origin_access_key = Azucat.config.access_key
        @self.stub(:get_access_token)
      end
      after do
        Azucat.config.access_key = @origin_access_key
      end

      it "get access token" do
        Azucat.config.access_key = nil
        @self.should_receive(:get_access_token)
        @self.send(:setup_config)
      end
    end

    context "when twitter access key exists" do
      it "set @config variable" do
        config = @self.instance_variable_get(:@config)
        config[:oauth][:access_key].should == Azucat.config.access_key
      end
    end
  end

  context "in default" do
    it "set @config, @client and @info" do
      %w[@config @client @info].map { |name|
        @self.instance_variable_get(name)
      }.should be_all
    end

    context "when receive tweet that includes one's screen name" do
      let(:tweet) { ?@ + @self.instance_variable_get(:@info)["screen_name"] }

      it "should notify the tweet" do
        Notify.should_receive(:notify)
        Azucat::Notify.notify(:filtered => tweet)
      end
    end
  end

  describe "commands" do
    before do
      Azucat::Command.stub(:output)
    end

    describe "t|tweet <params>" do
      it "should tweet <params>" do
        @self.should_receive(:tweet).with("foo").exactly(2).times
        Azucat::Command.input("t foo")
        Azucat::Command.input("tweet foo")
      end
    end
  end
end
