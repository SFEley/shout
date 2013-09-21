describe Shout do
  describe "configuration" do
    it "can set the service" do
      Shout.service = 'foo'
      expect(Shout.service).to eq 'foo'
      Shout.service = nil   # cleanup
    end

    it "defaults the service to the application name" do
      expect($0).to end_with(Shout.service)
    end
  end

  describe "listener spawning" do
    let(:dummy) {double('Example Listener')}

    it "requires the named listener file" do
      expect(Shout).to receive(:require).with('shout/listeners/dummy').and_call_original
      Shout.listener :dummy
    end

    it "instantiates the listener object" do
      expect(Shout.listener :dummy).to be_a(Shout::Listeners::Dummy)
    end

  end

  context "as an included module" do
    class Dummy
      include Shout
      def speak(*args)
        shout *args
      end
    end

    let(:dummy) {Dummy.new}

    describe "class-level shouter" do
      it "is created upon access" do
        expect(Dummy.shouter).to be_a(Shout::Shouter)
      end

      it "uses the global service name" do
        expect(Dummy.shouter.service).to eq Shout.service
      end

      it "uses the class as a component name" do
        expect(Dummy.shouter.component).to eq 'Dummy'
      end

      it "can be set manually" do
        Dummy.shouter = :foo
        expect(Dummy.shouter).to eq :foo
        Dummy.shouter = nil  # clean up
      end
    end

    describe "instance-level shouter" do
      it "is the class shouter" do
        expect(dummy.send :shouter).to equal(Dummy.shouter)
      end

      it "is a protected method" do
        expect {dummy.shouter}.to raise_error(NoMethodError)
      end

      it "can be overridden" do
        dummy.send :shouter=, :bar
        expect(dummy.send :shouter).to equal :bar
      end
    end

    describe "#shout instance method" do
      let(:shouter) {double('object shouter')}

      before do
        dummy.send :shouter=, shouter
      end

      it "is a protected method" do
        expect {dummy.shout 'Boo!'}.to raise_error(NoMethodError)
      end

      it "delegates to the shouter" do
        expect(shouter).to receive(:shout).with('Howdy!')
        dummy.speak 'Howdy!'
      end

    end
  end
end
