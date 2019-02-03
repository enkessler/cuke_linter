module CukeLinter
  class TestModel < CukeModeler::Model

    include CukeModeler::Sourceable

  end
end


module CukeLinter
  module ModelFactory

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
