require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require "tempfile"

describe Azucat::Core do
  describe "configure" do
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

  describe "run threads" do
    it "lets classes to call .run method" do
      [
        Azucat::HTTPServer,
        Azucat::WebSocketServer,
        Azucat::Input,
        Azucat::Twitter,
        Azucat::IRC
      ].each { |klass| klass.should_receive(:run) }
      Azucat::Skype.send(:define_method, :run, proc { EM.stop_event_loop })
      Azucat.send(:run_threads)
    end
  end
end
