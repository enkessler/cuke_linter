require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::TestWithBadNameLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('TestWithBadNameLinter')
  end

  describe 'linting' do

    ['scenario', 'outline'].each do |model_type|

      context "with a #{model_type} that has a bad name" do

        context 'because its name contains a bad word' do

          ['test', 'check', 'verify'].each do |bad_word|

            let(:test_model) do
              model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: model_file_path)
              model.name = "#{bad_word} bad names are reported"

              model
            end

            it_should_behave_like 'a linter linting a bad model'

            it 'records a problem' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq('"Test", "Verify" and "Check" should not be used in scenario names.')
            end

          end

          context 'because bad words are case insensitive' do

            ['Test', 'TEST'].each do |bad_word|

              let(:test_model) do
                model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: model_file_path)
                model.name = "#{bad_word} bad names are reported"

                model
              end

              it_should_behave_like 'a linter linting a bad model'

              it 'records a problem' do
                result = subject.lint(test_model)

                expect(result[:problem]).to eq('"Test", "Verify" and "Check" should not be used in scenario names.')
              end

            end

          end

        end

        context 'a non-feature model' do

          let(:test_model) { CukeModeler::Model.new }

          it_should_behave_like 'a linter linting a good model'

        end

      end

    end

  end

end
