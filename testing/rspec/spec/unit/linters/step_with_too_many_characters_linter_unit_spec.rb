require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::StepWithTooManyCharactersLinter do

  let(:good_data) do
    CukeLinter::ModelFactory.generate_step_model(source_text: '* a short step')
  end

  let(:bad_data) do
    long_step = <<~EOL.delete("\n")
      * this is a very long string which will violate the linter 
      rule which expects step rules to have fewer than one hundred 
      and twenty characters
    EOL
    CukeLinter::ModelFactory.generate_step_model(source_text: long_step)
  end

  it_should_behave_like 'a linter at the unit level'
  it_should_behave_like 'a configurable linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('StepWithTooManyCharactersLinter')
  end

  describe 'linting' do
  
    let(:step_too_long_model) do
      source_chars = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
      max_length = 120 + 1
      step = (0...max_length).map {source_chars[rand(source_chars.length)] }.join
      CukeLinter::ModelFactory.generate_step_model(source_text: "* #{step}")
    end
    
    it 'reports a problem' do
      result = subject.lint(step_too_long_model)

      expect(result[:problem]).to match(/^Step is too long. \d+ characters found \(max 120\)/)
    end
  
  end

end
