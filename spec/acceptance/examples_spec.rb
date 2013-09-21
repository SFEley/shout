describe "Example Scripts" do
  let(:example_dir) {File.join File.dirname(__FILE__), '..', '..', 'examples'}

  describe "01_hello_world.rb" do
    let(:script) {`ruby #{File.join example_dir, '01_hello_world.rb'} 2>&1`}
    it "returns 'Hello, world!'", :pending do
      expect(script).to match /Hello, world!/
    end

  end

end
