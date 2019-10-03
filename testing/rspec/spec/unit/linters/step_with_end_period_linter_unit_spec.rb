require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::StepWithEndPeriodLinter do

  let(:model_file_path) { 'some_file_path' }

  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('StepWithEndPeriodLinter')
  end

  describe 'linting' do

    context "with a step that ends with a period" do

      let(:test_model) do
        CukeLinter::ModelFactory.generate_step_model(parent_file_path: model_file_path,
                                                     source_text:      '* with a period.')
      end

      it_should_behave_like 'a linter linting a bad model'


      it 'records a problem' do
        result = subject.lint(test_model)

        expect(result[:problem]).to match('Step ends with a period')
      end

    end

    context "with a step that does not end with a period" do

      let(:test_model) do
        CukeLinter::ModelFactory.generate_step_model(source_text: '* without a period')
      end

      it_should_behave_like 'a linter linting a good model'

    end

    context 'with a non-step model' do

      let(:test_model) { CukeModeler::Model.new }

      it_should_behave_like 'a linter linting a good model'

    end

  end
end
