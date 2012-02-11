require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Azucat::Output do
  describe "COLOR_MAP" do
    it "convert color code to color name" do
      Azucat::Output::COLOR_MAP["31"].should == "red"
      Azucat::Output::COLOR_MAP["91"].should == "intense-red"
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
        Azucat::Output.puts("").should be_nil
        Azucat::Output.puts(nil).should be_nil
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
          args.should == Azucat::Output.send(:htmlize, str)
        end
        STDOUT.should_receive(:puts) do |args|
          args.should == Azucat::Output.send(:unhtmlize, str)
        end
        Azucat::Output.puts(str)
      end
    end
  end

  describe "#colorize" do
    context "when passed nil or empty string" do
      it "return passed args" do
        Azucat::Output.colorize("").should == ""
        Azucat::Output.colorize(nil).should be_nil
      end
    end

    context "when passed string" do
      it "surround string with random color code" do
        str = "foo"
        Azucat::Output.colorize(str).should match(/\e\[\d+m#{str}\e\[0m/)
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
          Azucat::Output.colorize(" " * 10 + hash[:name]),
          hash[:tag],
          hash[:text]
        ]
        Azucat::Output.stringify(hash).should == expected
      end
    end

    context "when passed empty hash" do
      it "convert hash to string in the form of `name: [ tag] text`" do
        Azucat::Output.stringify({}).should == (" " * 14 + ": [    ] ")
      end
    end
  end

  describe "#htmlize" do
    it "convert ANSI color sequence to HTML tag" do
      ansi = "\e\[31m foo \e\[0m"
      html = '<span class="red"> foo </span>'
      Azucat::Output.send(:htmlize, ansi).should == html
    end
  end

  describe "#unhtmlize" do
    it "convert HTML entities to real characters" do
      entitied = %w[&amp; &lt; &gt; &apos; &quot;].join
      expected = %{&<>'"}
      Azucat::Output.send(:unhtmlize, entitied).should == expected
    end
  end

  describe "#color_class_from_codes" do
    it "convert ANSI color sequence numbers to color name" do
      name = "red green"
      Azucat::Output.send(:color_class_from_codes,   "31;32").should == name
      Azucat::Output.send(:color_class_from_codes, %w[31 32]).should == name
    end
  end

  describe "#uniform" do
    it "stringify hash" do
      Azucat::Output.send(:uniform, {}).should == Azucat::Output.stringify({})
    end

    it "remove linebreaks" do
      Azucat::Output.send(:uniform, "foo\n").should == "foo"
    end
  end
end
