require_relative '../../../environments/rspec_env'


RSpec.describe CukeLinter do

  it "has a version number" do
    expect(CukeLinter::VERSION).not_to be nil
  end

  it 'can lint' do
    expect(CukeLinter).to respond_to(:lint)
  end
end
