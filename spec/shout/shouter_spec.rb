require 'shout/shouter'

describe Shout::Shouter do

  let(:shouter) {described_class.new}

  it "defaults the service name to the module level" do
    expect(shouter.service).to eq Shout.service
  end

  it "defaults the component name to blank" do
    expect(shouter.component).to eq ''
  end


end
