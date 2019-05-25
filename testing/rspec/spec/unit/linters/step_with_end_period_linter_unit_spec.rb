require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::StepWithEndPeriodLinter do

  let(:good_data) do
    CukeLinter::ModelFactory.generate_step_model(source_text: '* without a period')
  end

  let(:bad_data) do
    CukeLinter::ModelFactory.generate_step_model(source_text: '* with a period.')
  end


  it_should_behave_like 'a linter at the unit level'


  it 'has a name' do
    expect(subject.name).to eq('StepWithEndPeriodLinter')
  end

  describe 'linting' do

    context "with a step that ends with a period" do

      let(:test_model) do
        CukeLinter::ModelFactory.generate_step_model(source_text: '* with a period.')
      end

      it 'records a problem' do
        result = subject.lint(test_model)

        expect(result[:problem]).to match('Step ends with a period')
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

    context "with a step that does not end with a period" do


      let(:test_model) do
        CukeLinter::ModelFactory.generate_step_model(source_text: '* without a period')
      end

      it 'does not record a problem' do
        expect(subject.lint(test_model)).to eq(nil)
      end

    end

    context 'with a non-step model' do

      let(:test_model) { CukeModeler::Model.new }

      it 'returns no result' do
        result = subject.lint(test_model)

        expect(result).to eq(nil)
      end

    end
  end
end
