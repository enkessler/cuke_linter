require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::FeatureWithoutNameLinter do

  let(:good_data) do
    CukeLinter::ModelFactory.generate_feature_model(source_text: 'Feature: some name')
  end

  let(:bad_data) do
    CukeLinter::ModelFactory.generate_feature_model(source_text: 'Feature:')
  end


  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('FeatureWithoutNameLinter')
  end

  describe 'linting' do

    context 'with a feature that has no name' do

      context 'because its name is empty' do

        let(:test_model) do
          model      = CukeLinter::ModelFactory.generate_feature_model(parent_file_path: 'path_to_file')
          model.name = ''

          model
        end

        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Feature does not have a name.')
        end

        it 'records the location of the problem' do
          test_model.source_line = 1
          result                 = subject.lint(test_model)
          expect(result[:location]).to eq('path_to_file:1')

          test_model.source_line = 3
          result                 = subject.lint(test_model)
          expect(result[:location]).to eq('path_to_file:3')
        end

      end

      context 'because its name is nil' do

        let(:test_model) do
          model      = CukeLinter::ModelFactory.generate_feature_model(parent_file_path: 'path_to_file')
          model.name = nil

          model
        end

        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to eq('Feature does not have a name.')
        end

        it 'records the location of the problem' do
          test_model.source_line = 1
          result                 = subject.lint(test_model)
          expect(result[:location]).to eq('path_to_file:1')

          test_model.source_line = 3
          result                 = subject.lint(test_model)
          expect(result[:location]).to eq('path_to_file:3')
        end

      end

    end

    context 'with a feature that does have a name' do

      let(:test_model) do
        model      = CukeLinter::ModelFactory.generate_feature_model
        model.name = 'foo'

        model
      end

      it 'does not record a problem' do
        expect(subject.lint(test_model)).to eq(nil)
      end

    end


    context 'a non-feature model' do

      let(:test_model) { CukeModeler::Model.new }

      it 'returns no result' do
        result = subject.lint(test_model)

        expect(result).to eq(nil)
      end

    end

  end

end
