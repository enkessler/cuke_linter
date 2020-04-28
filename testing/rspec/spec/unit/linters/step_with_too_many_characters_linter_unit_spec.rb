require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::StepWithTooManyCharactersLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'
  it_should_behave_like 'a configurable linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('StepWithTooManyCharactersLinter')
  end

  describe 'linting' do

    let(:default_character_threshold) { 80 }

    context 'when the step is too long' do

      let(:test_model) do
        step = 'x' * (default_character_threshold + 1)
        generate_step_model(parent_file_path: model_file_path,
                            source_text:      "* #{step}")
      end

      it_should_behave_like 'a linter linting a bad model'


      it 'reports a problem' do
        result = subject.lint(test_model)

        expect(result[:problem]).to match(/^Step is too long. \d+ characters found \(max 80\)/)
      end

      it 'includes the number of characters found in the problem record' do
        character_count = test_model.text.length
        result          = subject.lint(test_model)
        expect(result[:problem]).to eq("Step is too long. #{character_count} characters found (max 80)")

        test_model.text += 'x'
        result          = subject.lint(test_model) # rubocop:disable Layout/SpaceAroundOperators
        expect(result[:problem]).to eq("Step is too long. #{character_count + 1} characters found (max 80)")
      end

    end

    context 'when the step is the maximum length' do

      let(:test_model) do
        step = 'x' * default_character_threshold
        generate_step_model(source_text: "* #{step}")
      end

      it_should_behave_like 'a linter linting a good model'

    end

    context 'when the step is below the maximum length' do

      let(:test_model) do
        step = 'x' * (default_character_threshold - 1)
        generate_step_model(source_text: "* #{step}")
      end

      it_should_behave_like 'a linter linting a good model'

    end

    context 'when the step has no text' do

      let(:test_model) do
        model      = generate_step_model
        model.text = nil

        model
      end

      it_should_behave_like 'a linter linting a good model'

    end

    context 'a non-step model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end

  end

  describe 'configuration' do

    context 'with no configuration' do

      let(:default_character_threshold) { 80 }

      context 'because configuration never happened' do

        let(:default_model) do
          step = 'x' * (default_character_threshold + 1)
          generate_step_model(source_text: "* #{step}")
        end

        it 'defaults to a maximum of 80 characters' do
          result = subject.lint(default_model)

          expect(result[:problem]).to match(/^Step is too long. \d+ characters found \(max 80\)/)
        end

      end

      context 'because configuration did not set a step threshold' do
        let(:configuration) { {} }
        let(:configured_model) do
          subject.configure(configuration)
          step = 'x' * (default_character_threshold + 1)
          generate_step_model(source_text: "* #{step}")
        end

        it 'defaults to a maximum of 80 characters' do
          result = subject.lint(configured_model)

          expect(result[:problem]).to match(/^Step is too long. \d+ characters found \(max 80\)/)
        end

      end

    end

    context 'when configured' do
      let(:character_threshold) { 10 }
      let(:configuration) { { 'StepLengthThreshold' => character_threshold } }

      subject { linter = CukeLinter::StepWithTooManyCharactersLinter.new
                linter.configure(configuration)
                linter }

      let(:test_model) do
        step = 'x' * (character_threshold + 1)
        generate_step_model(source_text: "* #{step}")
      end

      it 'uses the maximum character length provided by configuration' do
        result = subject.lint(test_model)

        expect(result[:problem]).to match(/^Step is too long. \d+ characters found \(max 10\)/)
      end

    end

  end
end
