require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::StepWithTooManyCharactersLinter do

  it_should_behave_like 'a linter at the unit level'
  it_should_behave_like 'a configurable linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('StepWithTooManyCharactersLinter')
  end

end
