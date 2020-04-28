require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::FeatureWithTooManyDifferentTagsLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'
  it_should_behave_like 'a configurable linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('FeatureWithTooManyDifferentTagsLinter')
  end

  describe 'linting' do

    context 'with a feature that contains too many different tags' do

      let(:test_model) do
        model      = generate_feature_model(parent_file_path: model_file_path)
        model.tags = [CukeModeler::Tag.new('@1'),
                      CukeModeler::Tag.new('@2'),
                      CukeModeler::Tag.new('@3'),
                      CukeModeler::Tag.new('@4'),
                      CukeModeler::Tag.new('@5'),
                      CukeModeler::Tag.new('@6'),
                      CukeModeler::Tag.new('@7'),
                      CukeModeler::Tag.new('@8'),
                      CukeModeler::Tag.new('@9'),
                      CukeModeler::Tag.new('@10'),
                      CukeModeler::Tag.new('@11')]

        model
      end

      it_should_behave_like 'a linter linting a bad model'


      it 'records a problem' do
        result = subject.lint(test_model)

        expect(result[:problem]).to match(/^Feature contains too many different tags. \d+ tags found \(max 10\)\.$/)
      end

      it 'includes the number of different tags found in the problem record' do
        unique_tag_count = test_model.tags.count
        result           = subject.lint(test_model)
        expect(result[:problem])
          .to eq("Feature contains too many different tags. #{unique_tag_count} tags found (max 10).")

        test_model.tags << CukeModeler::Tag.new('@had_better_be_unique')
        result = subject.lint(test_model)
        expect(result[:problem])
          .to eq("Feature contains too many different tags. #{unique_tag_count + 1} tags found (max 10).")
      end

      it 'only counts unique tags' do
        model      = generate_feature_model
        model.tags = []
        100.times { model.tags << CukeModeler::Tag.new('@A') }

        result = subject.lint(model)

        expect(result).to eq(nil)
      end

      context 'with child models' do

        let(:test_model) do
          model      = generate_feature_model
          model.tags = [CukeModeler::Tag.new('@1'),
                        CukeModeler::Tag.new('@2'),
                        CukeModeler::Tag.new('@3'),
                        CukeModeler::Tag.new('@4'),
                        CukeModeler::Tag.new('@5'),
                        CukeModeler::Tag.new('@6'),
                        CukeModeler::Tag.new('@7'),
                        CukeModeler::Tag.new('@8'),
                        CukeModeler::Tag.new('@9'),
                        CukeModeler::Tag.new('@10'),
                        CukeModeler::Tag.new('@11')]

          # Not all model types are a test but the models dont care and it's good enough for the test
          model.tests = [child_model]

          model
        end

        # Descriptive variable name, just in case what kinds of elements are taggable ever changes
        taggable_elements = ['feature', 'scenario', 'outline', 'example']

        taggable_elements.each do |model_type|

          context 'that have tags' do

            let(:child_model) do
              model      = send("generate_#{model_type}_model")
              model.tags = [CukeModeler::Tag.new('@12'),
                            CukeModeler::Tag.new('@13'),
                            CukeModeler::Tag.new('@14')]

              model
            end

            it "considers tags from a #{model_type}" do
              result = subject.lint(test_model)
              expect(result[:problem]).to eq('Feature contains too many different tags. 14 tags found (max 10).')
            end

          end

          context 'that do not have tags' do

            context 'because their tags are empty' do

              let(:child_model) do
                model      = send("generate_#{model_type}_model")
                model.tags = []

                model
              end

              it 'can handle the child model without problem' do
                expect { subject.lint(test_model) }.to_not raise_error
              end

            end

          end

        end

      end

    end


    context 'with a feature that does not contain too many different tags' do

      context 'because it contains 10 different tags' do

        let(:test_model) do
          model      = generate_feature_model
          model.tags = [CukeModeler::Tag.new('@1'),
                        CukeModeler::Tag.new('@2'),
                        CukeModeler::Tag.new('@3'),
                        CukeModeler::Tag.new('@4'),
                        CukeModeler::Tag.new('@5'),
                        CukeModeler::Tag.new('@6'),
                        CukeModeler::Tag.new('@7'),
                        CukeModeler::Tag.new('@8'),
                        CukeModeler::Tag.new('@9'),
                        CukeModeler::Tag.new('@10')]

          model
        end

        it_should_behave_like 'a linter linting a good model'

      end

      context 'because it contains fewer than 10 different tags' do

        let(:test_model) do
          model      = generate_feature_model
          model.tags = [CukeModeler::Tag.new('@1')]

          model
        end

        it_should_behave_like 'a linter linting a good model'

      end

      context 'because it contains no tags' do

        context 'because its tags are empty' do

          let(:test_model) do
            model      = generate_feature_model
            model.tags = []

            model
          end

          it_should_behave_like 'a linter linting a good model'

        end

        context 'because its tags are nil' do

          # NOTE: Not handling the case of the model's tags being nil because the model methods used in the
          # linter's implementation will themselves not work when the tags are nil.

        end

      end

    end


    describe 'configuration' do

      let(:default_tag_threshold) { 10 }


      describe 'tag threshold configuration' do

        context 'with no configuration' do

          context 'because configuration never happened' do

            let(:unconfigured_test_model) do
              model      = generate_feature_model
              model.tags = []
              (default_tag_threshold + 1).times { |count| model.tags << CukeModeler::Tag.new("@#{count}") }

              model
            end

            it 'defaults to a tag threshold of 10 tags' do
              result         = subject.lint(unconfigured_test_model)
              expected_count = unconfigured_test_model.tags.count

              expect(result[:problem])
                .to eq("Feature contains too many different tags. #{expected_count} tags found (max 10).")
            end

          end

          context 'because configuration did not set a tag threshold' do

            let(:configuration) { {} }
            let(:test_model) do
              model      = generate_feature_model
              model.tags = []
              (default_tag_threshold + 1).times { |count| model.tags << CukeModeler::Tag.new("@#{count}") }

              model
            end

            before(:each) do
              subject.configure(configuration)
            end

            it 'defaults to a tag threshold of 10 tags' do
              result = subject.lint(test_model)

              expect(result[:problem])
                .to eq("Feature contains too many different tags. #{test_model.tags.count} tags found (max 10).")
            end

          end

        end

        context 'with configuration' do

          let(:tag_threshold) { 3 }
          let(:configuration) { { 'TagCountThreshold' => tag_threshold } }

          before(:each) do
            subject.configure(configuration)
          end

          let(:test_model) do
            model      = generate_feature_model
            model.tags = []
            (tag_threshold + 1).times { |count| model.tags << CukeModeler::Tag.new("@#{count}") }

            model
          end

          it 'the tag threshold used is the configured value' do
            result         = subject.lint(test_model)
            expected_count = test_model.tags.count

            expect(result[:problem])
              .to eq("Feature contains too many different tags. #{expected_count} tags found (max #{tag_threshold}).")
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
