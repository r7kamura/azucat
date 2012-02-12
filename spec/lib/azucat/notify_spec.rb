require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Azucat::Notify do
  before do
    @self = Azucat::Notify
  end

  describe ".notify" do
    before { @self.register   /foo/ }
    after  { @self.unregister /foo/ }

    context "when passed args that match filter" do
      it "call Notify.notify" do
        Notify.should_receive(:notify)
        @self.notify(:filtered => "fooooo")
      end
    end

    context "when passed args that does not match filter" do
      it "does not call Notify.notify" do
        Notify.should_not_receive(:notify)
        @self.notify(:filtered => "booooo")
      end
    end
  end

  describe ".register" do
    context "when passed args that already exists" do
      it "does not registered redundantly" do
        2.times { @self.register /foo/ }
        @self.instance_variable_get(:@filters).should have(1).filters
      end
      after { @self.unregister /foo/ }
    end
  end

  describe ".unregister" do
    it "unregisters filter" do
      @self.register   /foo/
      @self.unregister /foo/
      @self.instance_variable_get(:@filters).should_not include(/foo/)
    end
  end

  describe ".match_any_filter?" do
    before  { @self.register   /foo/ }
    after   { @self.unregister /foo/ }
    subject { @self.send(:match_any_filter?, str) }

    context "when passed args included in filters" do
      let(:str) { "foo" }
      it { should be_true }
    end

    context "when passed args not included in filters" do
      let(:str) { "bar" }
      it { should be_false }
    end
  end
end
