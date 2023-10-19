RSpec.describe CukeLinter::ElementWithCommonTagsLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('ElementWithCommonTagsLinter')
  end

  describe 'linting' do

    ELEMENTS_WITH_TAGGABLE_CHILDREN.each do |model_type|

      context "with a #{model_type} that has common tags on all of its children" do

        let(:test_model) do
          model = send("generate_#{model_type}_model", parent_file_path: model_file_path)

          2.times do
            child_model      = generate_lintable_model
            child_model.tags = [generate_tag_model(source_text: '@same')]

            case model_type
              when 'feature'
                model.tests << child_model
              when 'outline'
                model.examples << child_model
              else
                raise(ArgumentError, "Don't know how to setup a '#{model_type}'. Add a new case?")
            end

          end

          model
        end

        it_should_behave_like 'a linter linting a bad model'


        it 'records a problem' do
          result = subject.lint(test_model)

          case model_type
            when 'feature'
              expect(result[:problem])
                .to match(/^All tests in Feature have tag '@\w+'\. Move tag to Feature level\.$/)
            when 'outline'
              expect(result[:problem])
                .to match(/^All Examples in Outline have tag '@\w+'\. Move tag to Outline level\.$/)
            else
              raise(ArgumentError, "Don't know how to verify a '#{model_type}'. Add a new case?")
          end
        end

        it 'includes the name of the common tag found in the problem record' do
          common_tag = test_model.children.first.tags.first.name
          result     = subject.lint(test_model)
          expect(result[:problem]).to match(/have tag '#{common_tag}'\./)

          test_model.children.first.tags = [generate_tag_model(source_text: '@still_same')]
          test_model.children.last.tags  = [generate_tag_model(source_text: '@still_same')]

          common_tag = test_model.children.first.tags.first.name
          result     = subject.lint(test_model)
          expect(result[:problem]).to match(/have tag '#{common_tag}'\./)
        end

      end

      context "with a #{model_type} that does not have common tags on all of its children" do

        context 'because none of their tags are common' do

          let(:test_model) do
            model = send("generate_#{model_type}_model", parent_file_path: model_file_path)

            2.times do |count|
              child_model      = generate_lintable_model
              child_model.tags = [generate_tag_model(source_text: "@tag_#{count}")]

              case model_type
                when 'feature'
                  model.tests << child_model
                when 'outline'
                  model.examples << child_model
                else
                  raise(ArgumentError, "Don't know how to setup a '#{model_type}'. Add a new case?")
              end

            end

            model
          end

          it_should_behave_like 'a linter linting a good model'

        end

        context 'because some of them have no tags' do

          context 'because their tags are empty' do

            let(:test_model) do
              model = send("generate_#{model_type}_model", parent_file_path: model_file_path)

              2.times do
                child_model      = generate_lintable_model
                child_model.tags = []

                case model_type
                  when 'feature'
                    model.tests << child_model
                  when 'outline'
                    model.examples << child_model
                  else
                    raise(ArgumentError, "Don't know how to setup a '#{model_type}'. Add a new case?")
                end

              end

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

          context 'because their tags are nil' do

            let(:test_model) do
              model = send("generate_#{model_type}_model", parent_file_path: model_file_path)

              2.times do
                child_model      = generate_lintable_model
                child_model.tags = nil

                case model_type
                  when 'feature'
                    model.tests << child_model
                  when 'outline'
                    model.examples << child_model
                  else
                    raise(ArgumentError, "Don't know how to setup a '#{model_type}'. Add a new case?")
                end

              end

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

        end

        context 'because the model only has one child' do

          let(:test_model) do
            model = send("generate_#{model_type}_model", parent_file_path: model_file_path)

            1.times do # rubocop:disable Lint/UselessTimes - Sticking with the same test structure as other similar tests
              child_model      = generate_lintable_model
              child_model.tags = [generate_tag_model(source_text: '@a_tag')]

              case model_type
                when 'feature'
                  model.tests << child_model
                when 'outline'
                  model.examples << child_model
                else
                  raise(ArgumentError, "Don't know how to setup a '#{model_type}'. Add a new case?")
              end

            end

            model
          end

          it_should_behave_like 'a linter linting a good model'

        end

        context 'because the model has no children' do

          context 'because the children are empty' do

            let(:test_model) do
              model = send("generate_#{model_type}_model", parent_file_path: model_file_path)

              case model_type
                when 'feature'
                  model.tests = []
                when 'outline'
                  model.examples = []
                else
                  raise(ArgumentError, "Don't know how to setup a '#{model_type}'. Add a new case?")
              end

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

          context 'because the children are nil' do

            let(:test_model) do
              model = send("generate_#{model_type}_model", parent_file_path: model_file_path)

              case model_type
                when 'feature'
                  model.tests = nil
                when 'outline'
                  model.examples = nil
                else
                  raise(ArgumentError, "Don't know how to setup a '#{model_type}'. Add a new case?")
              end

              model
            end

            it_should_behave_like 'a linter linting a good model'

          end

        end

      end

    end


    context 'a model that is not a type that has taggable children' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end

  end

end
