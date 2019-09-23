require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::ElementWithTooManyTagsLinter do

  let(:good_data) do
    model      = CukeLinter::ModelFactory.generate_scenario_model
    model.tags = [:tag_1]

    model
  end

  let(:bad_data) do
    model      = CukeLinter::ModelFactory.generate_scenario_model
    model.tags = [:tag_1,
                  :tag_2,
                  :tag_3,
                  :tag_4,
                  :tag_5,
                  :tag_6]

    model
  end


  it_should_behave_like 'a linter at the unit level'
  it_should_behave_like 'a configurable linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('ElementWithTooManyTagsLinter')
  end

  describe 'linting' do

    # Descriptive variable name, just in case what kinds of elements are taggable ever changes
    taggable_elements = ['feature', 'scenario', 'outline', 'example']

    taggable_elements.each do |model_type|

      context "with a #{model_type} that has too many tags" do

        let(:test_model) do
          model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
          model.tags = [:tag_1,
                        :tag_2,
                        :tag_3,
                        :tag_4,
                        :tag_5,
                        :tag_6]

          model
        end

        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to match(/^#{model_type.capitalize} has too many tags. \d+ tags found \(max 5\)\.$/)
        end

        it 'records the location of the problem' do
          test_model.source_line = 1
          result                 = subject.lint(test_model)
          expect(result[:location]).to eq('path_to_file:1')

          test_model.source_line = 3
          result                 = subject.lint(test_model)
          expect(result[:location]).to eq('path_to_file:3')
        end

        it 'includes the number of tags found in the problem record' do
          tag_count = test_model.tags.count
          result    = subject.lint(test_model)
          expect(result[:problem]).to eq("#{model_type.capitalize} has too many tags. #{tag_count} tags found (max 5).")

          test_model.tags << :another_tag
          result = subject.lint(test_model)
          expect(result[:problem]).to eq("#{model_type.capitalize} has too many tags. #{tag_count + 1} tags found (max 5).")
        end

      end

      context "with a #{model_type} that does not have too many tags" do

        context 'because it has 5 tags' do

          let(:test_model) do
            model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
            model.tags = [:tag_1,
                          :tag_2,
                          :tag_3,
                          :tag_4,
                          :tag_5]

            model
          end

          it 'does not record a problem' do
            expect(subject.lint(test_model)).to eq(nil)
          end

        end

        context 'because it has fewer than 5 tags' do

          let(:test_model) do
            model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
            model.tags = [:tag_1]

            model
          end

          it 'does not record a problem' do
            expect(subject.lint(test_model)).to eq(nil)
          end

        end

        context 'because it has no tags' do

          context 'because its tags are empty' do

            let(:test_model) do
              model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
              model.tags = []

              model
            end

            it 'does not record a problem' do
              expect(subject.lint(test_model)).to eq(nil)
            end

          end

          context 'because its tags are nil' do

            let(:test_model) do
              model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: 'path_to_file')
              model.tags = nil

              model
            end

            it 'does not record a problem' do
              expect(subject.lint(test_model)).to eq(nil)
            end

          end

        end

      end


      describe 'configuration' do

        let(:default_tag_threshold) { 5 }


        describe 'tag threshold configuration' do

          context 'with no configuration' do

            context 'because configuration never happened' do

              let(:unconfigured_test_model) do
                model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
                model.tags = []
                (default_tag_threshold + 1).times { model.tags << :a_tag }

                model
              end

              it 'defaults to a tag threshold of 5 tags' do
                result = subject.lint(unconfigured_test_model)

                expect(result[:problem]).to eq("#{model_type.capitalize} has too many tags. #{unconfigured_test_model.tags.count} tags found (max 5).")
              end

            end

            context 'because configuration did not set a tag threshold' do

              let(:configuration) { {} }
              let(:test_model) do
                model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
                model.tags = []
                (default_tag_threshold + 1).times { model.tags << :a_tag }

                model
              end

              before(:each) do
                subject.configure(configuration)
              end

              it 'defaults to a tag threshold of 5 tags' do
                result = subject.lint(test_model)

                expect(result[:problem]).to eq("#{model_type.capitalize} has too many tags. #{test_model.tags.count} tags found (max 5).")
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
              model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
              model.tags = []
              (tag_threshold + 1).times { model.tags << :a_tag }

              model
            end

            it 'the tag threshold used is the configured value' do
              result = subject.lint(test_model)

              expect(result[:problem]).to eq("#{model_type.capitalize} has too many tags. #{test_model.tags.count} tags found (max #{tag_threshold}).")
            end

          end

        end


        describe 'tag inheritance configuration' do

          let(:test_model_with_inherited_tags) do
            test_model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
            test_model.tags = []
            (default_tag_threshold).times { test_model.tags << :a_tag }

            ancestor_model      = CukeLinter::ModelFactory.generate_lintable_model
            ancestor_model.tags = [:an_extra_tag]

            test_model.parent_model = ancestor_model

            test_model
          end


          context 'with no configuration' do

            context 'because configuration never happened' do

              it 'does not include inherited tags' do
                result = subject.lint(test_model_with_inherited_tags)

                expect(result).to eq(nil)
              end

            end

            context 'because configuration did not set tag inheritance' do

              let(:configuration) { {} }

              before(:each) do
                subject.configure(configuration)
              end

              it 'does not include inherited tags' do
                result = subject.lint(test_model_with_inherited_tags)

                expect(result).to eq(nil)
              end

            end

          end

          context 'with configuration' do

            before(:each) do
              subject.configure(configuration)
            end

            context 'enabling tag inheritance' do

              let(:configuration) { { 'CountInheritedTags' => true } }

              it 'does include inherited tags' do
                result = subject.lint(test_model_with_inherited_tags)

                expect(result).to_not be_nil
                expect(result[:problem]).to eq("#{model_type.capitalize} has too many tags. #{test_model_with_inherited_tags.all_tags.count} tags found (max #{default_tag_threshold}).")
              end

            end

            context 'disabling tag inheritance' do

              let(:configuration) { { 'CountInheritedTags' => false } }

              it 'does not include inherited tags' do
                result = subject.lint(test_model_with_inherited_tags)

                expect(result).to eq(nil)
              end

            end

          end

        end

      end

    end


    context 'a non-taggable model' do

      let(:test_model) { CukeModeler::Model.new }

      it 'returns no result' do
        result = subject.lint(test_model)

        expect(result).to eq(nil)
      end

    end

  end

end
