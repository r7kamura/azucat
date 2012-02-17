require File.expand_path("../../spec_helper", File.dirname(__FILE__))
require "tempfile"
require "socket"

describe Azucat::Core do
  describe "#config" do
    context "when not set value" do
      it "return a instance of Hashie::Mash" do
        Azucat.config.should be_a_instance_of Hashie::Mash
      end

      it "set and get value by method call" do
        Azucat.config.foo = "foo"
        Azucat.config.foo.should == "foo"
      end
    end
  end

  describe "#run" do
    before do
      @runs = Azucat.send(:instance_variable_get, :@runs)
      Azucat.send(:instance_variable_set, :@runs, [])
    end

    after do
      Azucat.send(:instance_variable_set, :@runs, @runs)
    end

    it "register block and call it" do
      r = proc {}
      Azucat.run(&r)
      Azucat.run { Azucat.stop }
      r.should_receive(:call)
      Azucat.run
    end
  end

  describe "#configure" do
    before do
      Tempfile.new(".azucat").tap { |f| @path = f.path }.unlink
    end

    after do
      File.delete(@path)
    end

    context "when config file not exist" do
      it "create this" do
        File.should_not be_exist(@path)
        Azucat.send(:configure, :file => @path)
        File.should be_exist(@path)
      end
    end

    context "when config file exists" do
      before do
        File.open(@path, "w") do |f|
          f.puts "Azucat.config.test_flag = true"
        end
      end

      it "load this" do
        Azucat.config.test_flag.should be_false
        Azucat.send(:configure, :file => @path)
        Azucat.config.test_flag.should be_true
      end
    end
  end

  describe "#unused_port" do
    it "return unused port" do
      expect {
        TCPServer.open(Azucat.send(:unused_port)).close
      }.not_to raise_error(Errno::EADDRINUSE)
    end
  end
end
