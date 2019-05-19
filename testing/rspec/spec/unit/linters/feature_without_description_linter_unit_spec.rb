require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::FeatureWithoutDescriptionLinter do

  let(:good_data) do
    feature_text = 'Feature:
                      with a description'

    CukeLinter::ModelFactory.generate_feature_model(source_text: feature_text)
  end

  let(:bad_data) do
    feature_text = 'Feature: without a description'

    CukeLinter::ModelFactory.generate_feature_model(source_text: feature_text)
  end

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('FeatureWithoutDescriptionLinter')
  end
  
  describe 'linting' do
  
    context 'a feature with no description' do

      context 'because the description is empty' do

        let(:feature_with_no_description) do
          model             = CukeLinter::ModelFactory.generate_feature_model(parent_file_path: 'path_to_file')
          model.description = ''

          model
        end


        it 'records a problem' do
          result = subject.lint(feature_with_no_description)
          expect(result[:problem]).to eq('Feature has no description')
        end

        it 'records the location of the problem' do
          result = subject.lint(feature_with_no_description)
          expect(result[:location]).to eq('path_to_file:1')
        end
      end

      context 'because the description is nil' do

        let(:feature_with_no_description) do
          model             = CukeLinter::ModelFactory.generate_feature_model(parent_file_path: 'path_to_file')
          model.description = nil

          model
        end

        it 'records a problem' do
          result = subject.lint(feature_with_no_description)
          expect(result[:problem]).to eq('Feature has no description')
        end

        it 'records the location of the problem' do
          result = subject.lint(feature_with_no_description)
          expect(result[:location]).to eq('path_to_file:1')
        end

      end
    end
    
    context 'a feature with a description' do
      
      let(:feature_with_a_description) do
        model_source = "Feature:\n  This feature has a description"
        CukeLinter::ModelFactory.generate_feature_model(source_text: model_source,
                                                        parent_file_path: 'path_to_file')
      end
      
      it 'does not record a problem' do
        result = subject.lint(feature_with_a_description)
        expect(result).to eq(nil)
      end
    end

    context 'a non-feature model' do
    
      it 'returns no results' do
        result = subject.lint(CukeModeler::Model.new)

        expect(result).to eq(nil)
      end
    end

  end
end
