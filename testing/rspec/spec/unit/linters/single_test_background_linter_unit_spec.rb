require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::SingleTestBackgroundLinter do

  let(:good_data) do
    CukeLinter::ModelFactory.generate_feature_model(source_text: 'Feature:
                                                                    Background:
                                                                      * a step
                                                                    Scenario:
                                                                    Scenario:').background
  end

  let(:bad_data) do
    CukeLinter::ModelFactory.generate_feature_model(source_text: 'Feature:
                                                                    Background:
                                                                      * a step
                                                                    Scenario:').background
  end


  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('SingleTestBackgroundLinter')
  end

  describe 'linting' do

    context 'with a background that affects only one test' do

      ['scenario', 'outline'].each do |model_type|

        context "and that test is a #{model_type}" do

          let(:test_model) do
            background_model = CukeLinter::ModelFactory.generate_feature_model(source_text: 'Feature:
                                                                                               Background:
                                                                                                 * a step').background

            background_model.parent_model.tests.clear
            background_model.parent_model.tests << CukeLinter::ModelFactory.send("generate_#{model_type}_model")

            background_model
          end

          it 'records a problem' do
            result = subject.lint(test_model)

            expect(result[:problem]).to match('Background used with only one test')
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

    end

    context 'with a background that affects multiple tests' do

      let(:test_model) do
        CukeLinter::ModelFactory.generate_feature_model(source_text: 'Feature:
                                                                        Background:
                                                                          * a step
                                                                        Scenario:
                                                                        Scenario Outline:
                                                                          * a step
                                                                        Examples:
                                                                          |param|
                                                                          |value|').background
      end

      it 'does not record a problem' do
        expect(subject.lint(test_model)).to eq(nil)
      end

    end

    context 'with a background that affects no tests' do

      let(:test_model) do
        CukeLinter::ModelFactory.generate_feature_model(source_text: 'Feature:
                                                                        Background:
                                                                          * a step').background
      end

      it 'does not record a problem' do
        expect(subject.lint(test_model)).to eq(nil)
      end

    end

    context 'with a non-background model' do

      let(:test_model) { CukeModeler::Model.new }

      it 'returns no result' do
        result = subject.lint(test_model)

        expect(result).to eq(nil)
      end

    end
  end
end
