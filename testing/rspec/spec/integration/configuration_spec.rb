require_relative '../../../../environments/rspec_env'

RSpec.describe CukeLinter do

  describe 'configuration' do

    let(:test_model_tree) { CukeLinter::ModelFactory.generate_lintable_model }
    let(:test_linters) { [CukeLinter::LinterFactory.generate_fake_linter] }
    let(:test_formatters) { [[CukeLinter::FormatterFactory.generate_fake_formatter, "#{CukeLinter::FileHelper::create_directory}/junk_output_file.txt"]] }
    let(:linting_options) { { model_trees: [test_model_tree], linters: test_linters, formatters: test_formatters } }


    it 'unregisters disabled linters' do
      config             = { 'FakeLinter1' => { 'Enabled' => false } }
      configuration_file = CukeLinter::FileHelper.create_file(name: '.cuke_linter', extension: '', text: config.to_yaml)

      CukeLinter.register_linter(linter: CukeLinter::LinterFactory.generate_fake_linter(name: 'FakeLinter1'), name: 'FakeLinter1')
      expect(subject.registered_linters['FakeLinter1']).to_not be nil

      subject.load_configuration(config_file_path: configuration_file)

      expect(subject.registered_linters['FakeLinter1']).to be nil
    end

    it 'can apply a property to all linters' do
      configuration = { 'AllLinters' => { 'Enabled' => false } }

      # Restore the default linters
      CukeLinter.reset_linters

      # Also add some custom ones
      CukeLinter.register_linter(linter: CukeLinter::LinterFactory.generate_fake_linter, name: 'Foo')


      subject.load_configuration(config: configuration)

      expect(subject.registered_linters).to be_empty
    end

    it 'uses linter specific properties over general properties' do
      configuration = { 'AllLinters'  => { 'Enabled' => false },
                        'FakeLinter1' => { 'Enabled' => true } }

      CukeLinter.register_linter(linter: CukeLinter::LinterFactory.generate_fake_linter, name: 'FakeLinter1')
      expect(subject.registered_linters['FakeLinter1']).to_not be nil

      subject.load_configuration(config: configuration)

      expect(subject.registered_linters['FakeLinter1']).to_not be nil
    end

    it 'even unregisters non-configurable disabled linters' do
      config                  = { 'FakeLinter' => { 'Enabled' => false } }
      configuration_file      = CukeLinter::FileHelper.create_file(name: '.cuke_linter', extension: '', text: config.to_yaml)
      non_configurable_linter = CukeLinter::LinterFactory.generate_fake_linter(name: 'FakeLinter')
      non_configurable_linter.instance_eval('undef :configure')

      CukeLinter.register_linter(linter: non_configurable_linter, name: 'FakeLinter')
      expect(subject.registered_linters['FakeLinter']).to_not be nil

      subject.load_configuration(config_file_path: configuration_file)

      expect(subject.registered_linters['FakeLinter']).to be nil
    end

    it 'uses the default configuration file in the current directory if no configuration file is provided' do
      config             = { 'FakeLinter1' => { 'Enabled' => false } }
      configuration_file = CukeLinter::FileHelper.create_file(name: '.cuke_linter', extension: '', text: config.to_yaml)

      CukeLinter.register_linter(linter: CukeLinter::LinterFactory.generate_fake_linter(name: 'FakeLinter1'), name: 'FakeLinter1')
      expect(subject.registered_linters['FakeLinter1']).to_not be nil

      Dir.chdir(File.dirname(configuration_file)) do
        subject.load_configuration
      end

      expect(subject.registered_linters['FakeLinter1']).to be nil
    end

    it 'raises an exception if no default configuration file is found and no configuration or file is provided' do
      some_empty_directory = CukeLinter::FileHelper.create_directory

      Dir.chdir(File.dirname(some_empty_directory)) do
        expect { subject.load_configuration }.to raise_error('No configuration or configuration file given and no .cuke_linter file found')
      end
    end

    it 'configures every linter for which it has a configuration' do
      config = { 'FakeLinter1' => { 'Problem' => 'My custom message for FakeLinter1' },
                 'FakeLinter2' => { 'Problem' => 'My custom message for FakeLinter2' } }

      CukeLinter.register_linter(linter: CukeLinter::LinterFactory.generate_fake_linter(name: 'FakeLinter1'), name: 'FakeLinter1')
      CukeLinter.register_linter(linter: CukeLinter::LinterFactory.generate_fake_linter(name: 'FakeLinter2'), name: 'FakeLinter2')
      linting_options.delete(:linters)

      subject.load_configuration(config: config)
      results = subject.lint(linting_options)

      expect(results).to match_array([{ linter: 'FakeLinter1', location: 'path_to_file:1', problem: 'My custom message for FakeLinter1' },
                                      { linter: 'FakeLinter2', location: 'path_to_file:1', problem: 'My custom message for FakeLinter2' }])
    end

    it "does not try to configure linters that don't know how to be configured" do
      config                  = { 'FakeLinter' => { 'Problem' => 'My custom message for FakeLinter' } }
      non_configurable_linter = CukeLinter::LinterFactory.generate_fake_linter(name: 'FakeLinter')
      non_configurable_linter.instance_eval('undef :configure')

      CukeLinter.clear_registered_linters
      CukeLinter.register_linter(linter: non_configurable_linter, name: 'FakeLinter')
      linting_options.delete(:linters)

      subject.load_configuration(config: config)
      results = subject.lint(linting_options)

      expect(results).to match_array([{ linter: 'FakeLinter', location: 'path_to_file:1', problem: 'FakeLinter problem' }])
    end

  end

end
