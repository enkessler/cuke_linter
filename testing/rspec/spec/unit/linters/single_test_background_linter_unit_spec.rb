require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::SingleTestBackgroundLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('SingleTestBackgroundLinter')
  end

  describe 'linting' do

    context 'with a background that affects only one test' do

      ['scenario', 'outline'].each do |model_type|

        context "and that test is a #{model_type}" do

          let(:test_model) do
            background_model = generate_feature_model(parent_file_path: model_file_path,
                                                      source_text:      'Feature:
                                                                           Background:
                                                                             * a step').background

            background_model.parent_model.tests.clear
            background_model.parent_model.tests << send("generate_#{model_type}_model")

            background_model
          end

          it_should_behave_like 'a linter linting a bad model'


          it 'records a problem' do
            result = subject.lint(test_model)

            expect(result[:problem]).to match('Background used with only one test')
          end

        end

      end

    end

    context 'with a background that affects multiple tests' do

      let(:test_model) do
        generate_feature_model(source_text: 'Feature:
                                               Background:
                                                 * a step
                                               Scenario:
                                               Scenario Outline:
                                                 * a step
                                               Examples:
                                                 |param|
                                                 |value|').background
      end

      it_should_behave_like 'a linter linting a good model'

    end

    context 'with a background that affects no tests' do

      let(:test_model) do
        generate_feature_model(source_text: 'Feature:
                                               Background:
                                                 * a step').background
      end

      it_should_behave_like 'a linter linting a good model'

    end

    context 'with a non-background model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end

  end
end
