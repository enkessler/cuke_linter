module CukeLinter

  # A simple model used for testing

  class TestModel < CukeModeler::Model

    include CukeModeler::Sourceable

  end
end


module CukeLinter

  # A helper module that generates various models for use in testing

  module ModelFactory

    def self.generate_feature_model(source_text: 'Feature:', parent_file_path: 'path_to_file')
      fake_file_model      = CukeModeler::FeatureFile.new
      fake_file_model.path = parent_file_path

      model              = CukeModeler::Feature.new(source_text)
      model.parent_model = fake_file_model

      model
    end

    def self.generate_example_model(source_text: 'Examples:', parent_file_path: 'path_to_file')
      fake_file_model      = CukeModeler::FeatureFile.new
      fake_file_model.path = parent_file_path

      model              = CukeModeler::Example.new(source_text)
      model.parent_model = fake_file_model

      model
    end

    def self.generate_outline_model(source_text: "Scenario Outline:\n*a step\nExamples:\n|param|", parent_file_path: 'path_to_file')
      fake_file_model      = CukeModeler::FeatureFile.new
      fake_file_model.path = parent_file_path

      model              = CukeModeler::Outline.new(source_text)
      model.parent_model = fake_file_model

      model
    end

    def self.generate_scenario_model(source_text: 'Scenario:', parent_file_path: 'path_to_file')
      fake_file_model      = CukeModeler::FeatureFile.new
      fake_file_model.path = parent_file_path

      model              = CukeModeler::Scenario.new(source_text)
      model.parent_model = fake_file_model

      model
    end

    def self.generate_lintable_model(parent_file_path: 'path_to_file', source_line: '1', children: [])
      fake_file_model      = CukeModeler::FeatureFile.new
      fake_file_model.path = parent_file_path

      model              = CukeLinter::TestModel.new
      model.parent_model = fake_file_model
      model.source_line  = source_line

      model.define_singleton_method('children') do
        children
      end

      model
    end

  end
end
