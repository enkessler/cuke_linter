require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::ElementWithDuplicateTagsLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'
  it_should_behave_like 'a configurable linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('ElementWithDuplicateTagsLinter')
  end

  describe 'linting' do

    TAGGABLE_ELEMENTS.each do |model_type|

      context "with a #{model_type} that has duplicate tags" do

        let(:test_model) do
          model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model", parent_file_path: model_file_path)
          model.tags = [CukeLinter::ModelFactory.generate_tag_model(source_text: '@same'),
                        CukeLinter::ModelFactory.generate_tag_model(source_text: '@same')]

          model
        end

        it_should_behave_like 'a linter linting a bad model'


        it 'records a problem' do
          result = subject.lint(test_model)

          expect(result[:problem]).to match(/^#{model_type.capitalize} has duplicate tag '@\w+'\.$/)
        end

        it 'includes the name of the duplicate tag found in the problem record' do
          duplicate_tag = test_model.tags.first.name
          result        = subject.lint(test_model)
          expect(result[:problem]).to eq("#{model_type.capitalize} has duplicate tag '#{duplicate_tag}'.")

          test_model.tags = [CukeLinter::ModelFactory.generate_tag_model(source_text: '@still_same'),
                             CukeLinter::ModelFactory.generate_tag_model(source_text: '@still_same')]

          duplicate_tag = test_model.tags.first.name
          result        = subject.lint(test_model)
          expect(result[:problem]).to eq("#{model_type.capitalize} has duplicate tag '#{duplicate_tag}'.")
        end

      end

      context "with a #{model_type} that does not have duplicate tags" do

        context 'because none of it tags are duplicates' do

          let(:test_model) do
            model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
            model.tags = [CukeLinter::ModelFactory.generate_tag_model(source_text: '@foo'),
                          CukeLinter::ModelFactory.generate_tag_model(source_text: '@bar')]

            model
          end

          it_should_behave_like 'a linter linting a good model'

        end

        context 'because it has no tags' do

          context 'because its tags are empty' do

            let(:test_model) do
              model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
              model.tags = []

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

          context 'because its tags are nil' do

            let(:test_model) do
              model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
              model.tags = nil

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

        end

      end


      describe 'configuration' do

        describe 'tag inheritance configuration' do

          let(:test_model_with_inherited_tags) do
            test_model      = CukeLinter::ModelFactory.send("generate_#{model_type}_model")
            test_model.tags = [CukeLinter::ModelFactory.generate_tag_model(source_text: '@same')]

            distant_ancestor_model      = CukeLinter::ModelFactory.generate_lintable_model
            distant_ancestor_model.tags = [CukeLinter::ModelFactory.generate_tag_model(source_text: '@same')]
            ancestor_model              = CukeLinter::ModelFactory.generate_lintable_model

            # Adding an extra ancestor in the chain in order to make sure that the linter isn't just checking the parent model
            ancestor_model.parent_model = distant_ancestor_model
            test_model.parent_model     = ancestor_model

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

              let(:configuration) { { 'IncludeInheritedTags' => true } }

              it 'does include inherited tags' do
                result = subject.lint(test_model_with_inherited_tags)

                expect(result).to_not be_nil
                expect(result[:problem]).to match(/#{model_type.capitalize} has duplicate tag '@\w+'\./)
              end

            end

            context 'disabling tag inheritance' do

              let(:configuration) { { 'IncludeInheritedTags' => false } }

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

      it_should_behave_like 'a linter linting a good model'

    end

  end

end
