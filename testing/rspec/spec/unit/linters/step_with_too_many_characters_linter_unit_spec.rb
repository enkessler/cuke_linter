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
  
    let(:default_character_threshold) { 80 }
  
    context 'because the step is too long' do

      let(:step_too_long_model) do
        step = 'x' * (default_character_threshold + 1)
        CukeLinter::ModelFactory.generate_step_model(source_text: "* #{step}")
      end
    
      it 'reports a problem' do
        result = subject.lint(step_too_long_model)

        expect(result[:problem]).to match(/^Step is too long. \d+ characters found \(max 80\)/)
      end
    
      it 'records the location of the problem' do
        result = subject.lint(step_too_long_model)
      
        expect(result[:location]).to eq('path_to_file:4')
      end

    end
    
    context 'when the step is the maximum length' do
      
      let(:step_mex_length_model) do
        step = 'x' * default_character_threshold
        CukeLinter::ModelFactory.generate_step_model(source_text: "* #{step}")
      end
      
      it 'does not record a problem' do
        result = subject.lint(step_mex_length_model)
        expect(result).to eq(nil)
      end
      
    end
  
  end

  describe 'configuration' do
    
    let(:default_character_threshold) { 80 }
    
    context 'because configuration never happened' do
    
      let(:default_model) do
        step = 'x' * (default_character_threshold + 1)
        CukeLinter::ModelFactory.generate_step_model(source_text: "* #{step}")
      end
      
      it 'defaults to a maximum of 80 characters' do
        expect(subject.step_length_threshold).to eq default_character_threshold
        
        result = subject.lint(default_model)
        
        expect( result[:problem]).to match(/^Step is too long. \d+ characters found \(max 80\)/)
      end
      
    end
    
    context 'because configuration did not set a step threshold' do
      let(:configuration) { {} }
      let(:configured_model) do
        subject.configure(configuration)
        step = 'x' * (default_character_threshold + 1)
        CukeLinter::ModelFactory.generate_step_model(source_text: "* #{step}")
      end

      it 'defaults to a maximum of 80 characters' do
        expect(subject.step_length_threshold).to eq default_character_threshold
        
        result = subject.lint(configured_model)
        
        expect( result[:problem]).to match(/^Step is too long. \d+ characters found \(max 80\)/)
      end

    end

    context 'when configured' do
      let(:character_threshold) { 10 }
      let(:configuration) { {'StepLengthThreshold' => character_threshold} }
      let(:configured_model) do
        subject.configure(configuration)
        step = 'x' * (character_threshold + 1)
        CukeLinter::ModelFactory.generate_step_model(source_text: "* #{step}")
      end
      
      it 'uses the maximum character length provided by configuration' do
        result = subject.lint(configured_model)
        
        expect( result[:problem]).to match(/^Step is too long. \d+ characters found \(max 10\)/)
        expect(subject.step_length_threshold).to eq(character_threshold)
      end
      
    end
    
    context 'a non-test model' do

      let(:test_model) { CukeModeler::Model.new }

      it 'returns no result' do
        result = subject.lint(test_model)

        expect(result).to eq(nil)
      end

    end
  end
end
