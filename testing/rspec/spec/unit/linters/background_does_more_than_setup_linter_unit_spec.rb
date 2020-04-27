require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::BackgroundDoesMoreThanSetupLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'
  it_should_behave_like 'a configurable linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('BackgroundDoesMoreThanSetupLinter')
  end

  describe 'linting' do

    context 'a background with action steps' do

      let(:test_model) do
        generate_background_model(parent_file_path: model_file_path,
                                  source_text:      'Background:
                                                       When something')
      end

      it_should_behave_like 'a linter linting a bad model'


      it 'records a problem' do
        result = subject.lint(test_model)

        expect(result[:problem]).to eq('Background has non-setup steps')
      end

    end

    context 'a background with verification steps' do

      let(:test_model) do
        generate_background_model(parent_file_path: model_file_path,
                                  source_text:      'Background:
                                                       Then something')
      end

      it_should_behave_like 'a linter linting a bad model'


      it 'records a problem' do
        result = subject.lint(test_model)

        expect(result[:problem]).to eq('Background has non-setup steps')
      end

    end

    context 'a background with only setup steps' do

      let(:test_model) do
        gherkin = 'Background:
                       Given something
                       * (plus something)'

        generate_background_model(source_text: gherkin)
      end

      it_should_behave_like 'a linter linting a good model'

    end


    describe 'configuration' do

      let(:test_model) do
        generate_background_model
      end

      context 'with configuration' do

        before(:each) do
          subject.configure(configuration)
        end

        context "with a configured 'When' keyword" do

          let(:when_keyword) { 'Foo' }
          let(:configuration) { { 'When' => when_keyword } }

          it "uses the configured 'When' keyword" do
            test_model.steps.first.keyword = when_keyword

            result = subject.lint(test_model)

            expect(result).to_not be_nil
          end

        end

        context "with a configured 'Then' keyword" do

          let(:then_keyword) { 'Foo' }
          let(:configuration) { { 'Then' => then_keyword } }

          it "uses the configured 'Then' keyword" do
            test_model.steps.first.keyword = then_keyword

            result = subject.lint(test_model)

            expect(result).to_not be_nil
          end

        end

      end

      context 'without configuration' do

        context 'because configuration never happened' do

          it "uses the default 'When' keyword" do
            test_model.steps.first.keyword = CukeLinter::DEFAULT_WHEN_KEYWORD

            result = subject.lint(test_model)

            expect(result).to_not be_nil
          end

          it "uses the default 'Then' keyword" do
            test_model.steps.first.keyword = CukeLinter::DEFAULT_THEN_KEYWORD

            result = subject.lint(test_model)

            expect(result).to_not be_nil
          end

        end

        context "because configuration did not set a 'When' keyword" do

          before(:each) do
            subject.configure(configuration)
          end

          let(:configuration) { {} }

          it "uses the default 'When' keyword" do
            test_model.steps.first.keyword = CukeLinter::DEFAULT_WHEN_KEYWORD

            result = subject.lint(test_model)

            expect(result).to_not be_nil
          end

        end

        context "because configuration did not set a 'Then' keyword" do

          before(:each) do
            subject.configure(configuration)
          end

          let(:configuration) { {} }

          it "uses the default 'Then' keyword" do
            test_model.steps.first.keyword = CukeLinter::DEFAULT_THEN_KEYWORD

            result = subject.lint(test_model)

            expect(result).to_not be_nil
          end

        end

      end

    end


    context 'a non-background model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end
  end
end
