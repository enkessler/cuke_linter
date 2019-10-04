require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::BackgroundDoesMoreThanSetupLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('BackgroundDoesMoreThanSetupLinter')
  end

  describe 'linting' do

    context 'a background with action steps' do

      let(:test_model) do
        CukeLinter::ModelFactory.generate_background_model(parent_file_path: model_file_path,
                                                           source_text:      'Background:
                                                                                When something')
      end

      it_should_behave_like 'a linter linting a bad model'


      it 'records a problem' do
        result = subject.lint(test_model)

        expect(result[:problem]).to eq('Background has non-setup steps')
      end

    end

    context 'a background with verification steps' do

      let(:test_model) do
        CukeLinter::ModelFactory.generate_background_model(parent_file_path: model_file_path,
                                                           source_text:      'Background:
                                                                                Then something')
      end

      it_should_behave_like 'a linter linting a bad model'


      it 'records a problem' do
        result = subject.lint(test_model)

        expect(result[:problem]).to eq('Background has non-setup steps')
      end

    end

    context 'a background with only setup steps' do

      let(:test_model) do
        gherkin = 'Background:
                       Given something
                       * (plus something)'

        CukeLinter::ModelFactory.generate_background_model(source_text: gherkin)
      end

      it_should_behave_like 'a linter linting a good model'

    end

    context 'a non-background model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end
  end
end
