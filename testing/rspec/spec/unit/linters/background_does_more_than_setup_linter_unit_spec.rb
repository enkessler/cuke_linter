require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::BackgroundDoesMoreThanSetupLinter do

  let(:good_data) do
    CukeLinter::ModelFactory.generate_background_model(source_text: 'Background:
                                                                       Given something')
  end

  let(:bad_data) do
    CukeLinter::ModelFactory.generate_background_model(source_text: 'Background:
                                                                       When something')
  end


  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('BackgroundDoesMoreThanSetupLinter')
  end

  describe 'linting' do

    context 'a background with action steps' do

      let(:test_model) do
        CukeLinter::ModelFactory.generate_background_model(source_text: 'Background:
                                                                           When something')
      end

      it 'records a problem' do
        result = subject.lint(test_model)

        expect(result[:problem]).to eq('Background has non-setup steps')
      end

      it 'records the location of the problem' do
        model = CukeLinter::ModelFactory.generate_background_model(parent_file_path: 'path_to_file',
                                                                   source_text:      'Background:
                                                                                        When something')

        model.source_line = 1
        result            = subject.lint(model)
        expect(result[:location]).to eq('path_to_file:1')

        model.source_line = 3
        result            = subject.lint(model)
        expect(result[:location]).to eq('path_to_file:3')
      end

    end

    context 'a background with verification steps' do

      let(:test_model) do
        CukeLinter::ModelFactory.generate_background_model(source_text: 'Background:
                                                                           Then something')
      end

      it 'records a problem' do
        result = subject.lint(test_model)

        expect(result[:problem]).to eq('Background has non-setup steps')
      end

      it 'records the location of the problem' do
        model = CukeLinter::ModelFactory.generate_background_model(parent_file_path: 'path_to_file',
                                                                   source_text:      'Background:
                                                                                        Then something')

        model.source_line = 1
        result            = subject.lint(model)
        expect(result[:location]).to eq('path_to_file:1')

        model.source_line = 3
        result            = subject.lint(model)
        expect(result[:location]).to eq('path_to_file:3')
      end

    end

    context 'a background with only setup steps' do

      context 'with a scenario' do

        let(:test_model) do
          gherkin = 'Background:
                       Given something
                       * (plus something)'

          CukeLinter::ModelFactory.generate_background_model(source_text: gherkin)
        end

        it 'does not record a problem' do
          expect(subject.lint(test_model)).to eq(nil)
        end

      end

    end

    context 'a non-background model' do

      it 'returns no result' do
        result = subject.lint(CukeModeler::Model.new)

        expect(result).to eq(nil)
      end

    end
  end
end
