require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Azucat::Output do
  before do
    @self = Azucat::Output
  end

  describe "COLOR_MAP" do
    it "convert color code to color name" do
      @self::COLOR_MAP["31"].should == "red"
      @self::COLOR_MAP["91"].should == "intense-red"
    end
  end

  describe "#puts" do
    context "when passed nil or empty string" do
      before do
        @channel = mock("channel")
        Azucat.send(:configure, :channel => @channel)
      end

      it "do nothing and return nil" do
        @channel.should_not_receive(:<<)
        @self.puts("").should be_nil
        @self.puts(nil).should be_nil
      end
    end

    context "when passed string" do
      before do
        @channel = mock("channel")
        Azucat.send(:configure, :channel => @channel)
      end

      it "make it up and push to channel and STDOUT" do
        str = "\e\[31m &lt;foo&gt; \e\[0m"
        @channel.should_receive(:<<) do |args|
          args.should == @self.send(:htmlize, str)
        end
        STDOUT.should_receive(:puts) do |args|
          args.should == @self.send(:unhtmlize, str)
        end
        @self.puts(str)
      end
    end
  end

  describe "#colorize" do
    context "when passed nil or empty string" do
      it "return passed args" do
        @self.colorize("").should == ""
        @self.colorize(nil).should be_nil
      end
    end

    context "when passed string" do
      it "surround string with random color code" do
        str = "foo"
        @self.colorize(str).should match(/\e\[\d+m#{str}\e\[0m/)
      end
    end
  end

  describe "#stringify" do
    context "when passed correct hash" do
      it "convert hash to string in the form of `name: [ tag] text`" do
        hash = {
          :name => "name",
          :tag  => "tag",
          :text => "text"
        }
        expected = "%s: [ %s] %s" % [
          @self.colorize(" " * 10 + hash[:name]),
          hash[:tag],
          hash[:text]
        ]
        @self.stringify(hash).should == expected
      end
    end

    context "when passed empty hash" do
      it "convert hash to string in the form of `name: [ tag] text`" do
        @self.stringify({}).should == (" " * 14 + ": [    ] ")
      end
    end
  end

  describe "#htmlize" do
    it "convert ANSI color sequence to HTML tag" do
      ansi = "\e\[31m foo \e\[0m"
      html = '<span class="red"> foo </span>'
      @self.send(:htmlize, ansi).should == html
    end
  end

  describe "#unhtmlize" do
    it "convert HTML entities to real characters" do
      entitied = %w[&amp; &lt; &gt; &apos; &quot;].join
      expected = %{&<>'"}
      @self.send(:unhtmlize, entitied).should == expected
    end
  end

  describe "#color_class_from_codes" do
    it "convert ANSI color sequence numbers to color name" do
      name = "red green"
      @self.send(:color_class_from_codes,   "31;32").should == name
      @self.send(:color_class_from_codes, %w[31 32]).should == name
    end
  end

  describe "#uniform" do
    it "stringify hash" do
      @self.send(:uniform, {}).should == @self.stringify({})
    end

    it "remove linebreaks" do
      @self.send(:uniform, "foo\n").should == "foo"
    end
  end
end