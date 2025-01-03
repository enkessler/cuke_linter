RSpec.describe CukeLinter::UniqueScenarioNamesLinter do
  let(:linter) { described_class.new }

  it_should_behave_like 'a linter at the unit level'

  it 'has a name' do
    expect(subject.name).to eq('UniqueScenarioNamesLinter')
  end

  before do
    # Reset the linter's state before each test
    described_class.instance_variable_set(:@scenario_names, {})
  end

  describe 'linting' do
    context 'with scenarios that have unique names within the same feature file' do
      let(:model_file_path) { 'features/unique_feature.feature' }

      let(:test_model) do
        feature_file = "
          Feature: Unique Scenarios Feature

            Scenario: First Unique Scenario
              Given a step

            Scenario: Second Unique Scenario
              When another step

            Scenario Outline: Unique Outline Scenario <param>
              Then a different step

            Examples:
              | param  |
              | Param1 |
              | Param2 |
        "
        generate_feature_model(source_text: feature_file, parent_file_path: model_file_path).tests
      end

      it_should_behave_like 'a linter linting a good model'

    end

    context 'with duplicate scenario names across different feature files' do
      let(:model_file_path_1) { 'features/first_feature.feature' }
      let(:model_file_path_2) { 'features/second_feature.feature' }

      let(:test_model) do
        feature_file_1 = "
          Feature: First Feature

            Scenario: Common Scenario Name
              Given some precondition
        "
        feature_file_2 = "
          Feature: Second Feature

            Scenario: Common Scenario Name
              When some action
        "
        model_1 = generate_feature_model(source_text: feature_file_1, parent_file_path: model_file_path_1).tests
        model_2 = generate_feature_model(source_text: feature_file_2, parent_file_path: model_file_path_2).tests
        model_1 + model_2
      end

      it_should_behave_like 'a linter linting a good model'

    end

    context 'with a scenario outline generating unique names' do
      let(:model_file_path) { 'features/unique_outline_feature.feature' }

      let(:test_model) do
        feature_file = "
          Feature: Unique Outline Feature

            Scenario Outline: Unique Scenario <input>
              Given a step

            Examples:
              | input |
              | One   |
              | Two   |
        "
        generate_feature_model(source_text: feature_file, parent_file_path: model_file_path).tests
      end

      it_should_behave_like 'a linter linting a good model'

    end

    context 'with a scenario that has a duplicate name within the same feature file' do
      let(:model_file_path) { 'path_to_file' }

      let(:model) do
        feature_file = "
          Feature: Sample Feature

            Scenario: Duplicate Scenario
              Given a step

            Scenario: Duplicate Scenario
              When another step
        "
        generate_feature_model(source_text: feature_file, parent_file_path: model_file_path).tests
      end

      it 'returns a detected problem' do
        results = model.map { |scenario| linter.lint(scenario) }.compact
        expect(results).to include(
          {
            problem:  "Scenario name 'Duplicate Scenario' is not unique.\n    Original name is on line: 4\n    Duplicate is on: 7",
            location: 'path_to_file:7'
          }
        )
      end

      it 'includes the problem and its location in its result' do
        results = model.filter_map { |scenario| linter.lint(scenario) }
        expect(results.first).to include(:problem, :location)
      end
    end

    context 'with a scenario outline generating duplicate names' do
      context 'when a scenario outline generates duplicate names' do

        let(:model) do
          feature_file = "
          Feature: Sample Feature with Scenario Outline
            Scenario Outline: Repeated Scenario Name Doing <input>
            Examples:
              | input          |
              | Something      |
              | Something      |
          "

          generate_feature_model(source_text: feature_file, parent_file_path: 'path_to_file').tests
        end

        it 'returns a detected problem' do
          results = model.map { |scenario| linter.lint(scenario) }.compact
          expect(results).to include(
            {
              problem:  "Scenario name created by Scenario Outline 'Repeated Scenario Name Doing Something' is not unique.\n    Original name is on line: 3\n    Duplicate is on: 3",
              location: 'path_to_file:3'
            }
          )
        end

        it 'includes the problem and its location in its result' do
          results = model.filter_map { |scenario| linter.lint(scenario) }
          expect(results.first).to include(:problem, :location)
        end
      end
      context 'when duplicates are generated between an outline and a regular scenario' do
        let(:model_file_path) { 'path_to_file' }

        let(:model) do
          feature_file = "
            Feature: Mixed Scenarios Feature

              Scenario: Unique Scenario
                Given a unique step

              Scenario Outline: Unique Scenario
                When a step with <value>

              Examples:
                | value  |
                | Unique |
          "
          generate_feature_model(source_text: feature_file, parent_file_path: model_file_path).tests
        end

        it 'returns a detected problem' do
          results = model.map { |scenario| linter.lint(scenario) }.compact
          expect(results).to include(
            {
              problem:  "Scenario name created by Scenario Outline 'Unique Scenario' is not unique.\n    Original name is on line: 4\n    Duplicate is on: 7",
              location: 'path_to_file:7'
            }
          )
        end

        it 'includes the problem and its location in its result' do
          results = model.filter_map { |scenario| linter.lint(scenario) }
          expect(results.first).to include(:problem, :location)
        end
      end

      context 'when duplicates are generated by different outlines' do
        let(:model_file_path) { 'path_to_file' }

        let(:model) do
          feature_file = "
            Feature: Conflicting Outlines Feature

              Scenario Outline: Conflict Scenario <input>
                Given a step

              Examples:
                | input    |
                | Conflict |

              Scenario Outline: Conflict Scenario <input>
                When another step

              Examples:
                | input    |
                | Conflict |
          "
          generate_feature_model(source_text: feature_file, parent_file_path: model_file_path).tests
        end

        it 'returns a detected problem' do
          results = model.map { |scenario| linter.lint(scenario) }.compact
          expect(results).to include(
            {
              problem:  "Scenario name created by Scenario Outline 'Conflict Scenario Conflict' is not unique.\n    Original name is on line: 4\n    Duplicate is on: 11",
              location: 'path_to_file:11'
            }
          )
        end

        it 'includes the problem and its location in its result' do
          results = model.filter_map { |scenario| linter.lint(scenario) }
          expect(results.first).to include(:problem, :location)
        end
      end

      context 'when the outline has no placeholders in the name' do
        let(:model_file_path) { 'path_to_file' }

        let(:model) do
          feature_file = "
            Feature: No Placeholder Outline Feature

              Scenario Outline: Static Scenario Name
                Given a step

              Examples:
                | input  |
                | Value1 |
                | Value2 |
          "
          generate_feature_model(source_text: feature_file, parent_file_path: model_file_path).tests
        end

        it 'returns a detected problem' do
          results = model.map { |scenario| linter.lint(scenario) }.compact
          expect(results).to include(
            {
              problem:  "Scenario name created by Scenario Outline 'Static Scenario Name' is not unique.\n    Original name is on line: 4\n    Duplicate is on: 4",
              location: 'path_to_file:4'
            }
          )
        end

        it 'includes the problem and its location in its result' do
          results = model.filter_map { |scenario| linter.lint(scenario) }
          expect(results.first).to include(:problem, :location)
        end
      end
    end
  end
end
