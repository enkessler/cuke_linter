module CukeLinter

  # A simple model used for testing

  class TestModel < CukeModeler::Model

    include CukeModeler::Sourceable
    include CukeModeler::Taggable

    def initialize
      super

      @tags = []
    end

  end
end


module CukeLinter

  # A helper module that generates various models for use in testing

  module ModelFactory

    def self.included(klass)
      klass.include(Methods)
    end

    def self.extended(klass)
      klass.extend(Methods)
    end

    module Methods

      def generate_feature_model(source_text: 'Feature:', parent_file_path: 'path_to_file')
        fake_parent_model      = CukeModeler::FeatureFile.new
        fake_parent_model.path = parent_file_path

        model              = CukeModeler::Feature.new(source_text)
        model.parent_model = fake_parent_model

        fake_parent_model.feature = model

        model
      end

      def generate_feature_file_model
        model = CukeModeler::FeatureFile.new

        model
      end

      def generate_example_model(source_text: 'Examples:', parent_file_path: 'path_to_file')
        fake_parent_model = generate_outline_model(parent_file_path: parent_file_path)

        model              = CukeModeler::Example.new(source_text)
        model.parent_model = fake_parent_model

        model
      end

      def generate_outline_model(source_text: "Scenario Outline:", parent_file_path: 'path_to_file')
        fake_parent_model = generate_feature_model(parent_file_path: parent_file_path)

        model              = CukeModeler::Outline.new(source_text)
        model.parent_model = fake_parent_model

        model
      end

      def generate_scenario_model(source_text: 'Scenario:', parent_file_path: 'path_to_file')
        fake_parent_model = generate_feature_model(parent_file_path: parent_file_path)

        model              = CukeModeler::Scenario.new(source_text)
        model.parent_model = fake_parent_model

        model
      end

      def generate_background_model(source_text: "Background:\n* a step", parent_file_path: 'path_to_file')
        fake_parent_model = generate_feature_model(parent_file_path: parent_file_path)

        model              = CukeModeler::Background.new(source_text)
        model.parent_model = fake_parent_model

        model
      end

      def generate_step_model(source_text: '* a step', parent_file_path: 'path_to_file')
        fake_parent_model = generate_scenario_model(parent_file_path: parent_file_path)

        model              = CukeModeler::Step.new(source_text)
        model.parent_model = fake_parent_model

        model
      end

      def generate_tag_model(source_text: '@a_tag')
        CukeModeler::Tag.new(source_text)
      end

      def generate_lintable_model(parent_file_path: 'path_to_file', source_line: 1, children: [])
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

    extend Methods

  end
end
