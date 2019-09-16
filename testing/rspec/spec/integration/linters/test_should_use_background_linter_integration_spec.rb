require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestShouldUseBackgroundLinter do

  it_should_behave_like 'a linter at the integration level'

end
