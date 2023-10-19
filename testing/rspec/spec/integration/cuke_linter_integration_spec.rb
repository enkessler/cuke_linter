RSpec.describe CukeLinter do

  let(:test_model_tree) { generate_lintable_model }
  let(:test_linters) { [generate_fake_linter] }
  let(:test_formatters) { [[generate_fake_formatter, "#{create_directory}/junk_output_file.txt"]] }
  let(:linting_options) { { model_trees: [test_model_tree], linters: test_linters, formatters: test_formatters } }


  it 'returns the un-formatted linting data when linting' do
    results = subject.lint(**linting_options)

    expect(results).to eq([{ linter: 'FakeLinter', location: 'path_to_file:1', problem: 'FakeLinter problem' }])
  end

  it 'uses every formatter provided' do
    linting_options[:formatters] = [[generate_fake_formatter(name: 'Formatter1')],
                                    [generate_fake_formatter(name: 'Formatter2')]]

    expect { subject.lint(**linting_options) }.to output("Formatter1: FakeLinter problem: path_to_file:1\nFormatter2: FakeLinter problem: path_to_file:1\n").to_stdout # rubocop:disable Layout/LineLength
  end

  it "uses the 'pretty' formatter if none are provided" do
    linting_options.delete(:formatters)

    expect { subject.lint(**linting_options) }.to output(['FakeLinter',
                                                          '  FakeLinter problem',
                                                          '    path_to_file:1',
                                                          '',
                                                          '1 issues found',
                                                          ''].join("\n")).to_stdout
  end

  it 'outputs formatted linting data to the provided output location' do
    output_path                  = "#{create_directory}/output.txt"
    linting_options[:formatters] = [[generate_fake_formatter(name: 'Formatter1'),
                                     output_path]]

    expect { subject.lint(**linting_options) }.to_not output.to_stdout
    expect(File.read(output_path)).to eq("Formatter1: FakeLinter problem: path_to_file:1\n")
  end

  it 'outputs formatted data to STDOUT if not location is provided' do
    linting_options[:formatters] = [[generate_fake_formatter(name: 'Formatter1')]]

    expect { subject.lint(**linting_options) }.to output("Formatter1: FakeLinter problem: path_to_file:1\n").to_stdout
  end

  context 'with only model trees' do

    before(:each) do
      child_model      = generate_lintable_model(source_line: 3)
      parent_model     = generate_lintable_model(source_line: 5, children: [child_model])
      multi_node_tree  = parent_model
      single_node_tree = generate_lintable_model(source_line: 7)

      linting_options[:model_trees] = [single_node_tree, multi_node_tree]
      linting_options.delete(:file_paths)
    end

    it 'lints every model in each model tree' do
      results = subject.lint(**linting_options)

      expect(results).to match_array([{ linter:   'FakeLinter',
                                        location: 'path_to_file:3',
                                        problem:  'FakeLinter problem' },
                                      { linter:   'FakeLinter',
                                        location: 'path_to_file:5',
                                        problem:  'FakeLinter problem' },
                                      { linter:   'FakeLinter',
                                        location: 'path_to_file:7',
                                        problem:  'FakeLinter problem' }])
    end

  end

  context 'with only file paths' do

    before(:each) do
      @a_feature_file    = create_file(text: "\nFeature:", extension: '.feature')
      a_non_feature_file = create_file(text: 'Some text', extension: '.foo')
      @a_directory       = create_directory
      File.write("#{@a_directory}/test_feature.feature", 'Feature:')

      linting_options[:file_paths] = [@a_feature_file, a_non_feature_file, @a_directory]
      linting_options.delete(:model_trees)
    end

    # TODO: add a negative test that makes sure that non-included paths
    # aren't linted when paths are explicitly included

    it 'lints every model in each path' do
      results = subject.lint(**linting_options)

      expect(results).to match_array([{ linter:   'FakeLinter',
                                        location: @a_directory,
                                        problem:  'FakeLinter problem' },
                                      { linter:   'FakeLinter',
                                        location: "#{@a_directory}/test_feature.feature",
                                        problem:  'FakeLinter problem' },
                                      { linter:   'FakeLinter',
                                        location: "#{@a_directory}/test_feature.feature:1",
                                        problem:  'FakeLinter problem' },
                                      { linter:   'FakeLinter',
                                        location: @a_feature_file,
                                        problem:  'FakeLinter problem' },
                                      { linter:   'FakeLinter',
                                        location: "#{@a_feature_file}:2",
                                        problem:  'FakeLinter problem' }])
    end

  end

  context 'with both model trees and file paths' do

    before(:each) do
      a_model         = generate_lintable_model(source_line: 3)
      @a_feature_file = create_file(text: 'Feature:', extension: '.feature')

      linting_options[:model_trees] = [a_model]
      linting_options[:file_paths]  = [@a_feature_file]
    end


    it 'lints every model in each model tree and file path' do
      results = subject.lint(**linting_options)

      expect(results).to match_array([{ linter:   'FakeLinter',
                                        location: 'path_to_file:3',
                                        problem:  'FakeLinter problem' },
                                      { linter:   'FakeLinter',
                                        location: @a_feature_file,
                                        problem:  'FakeLinter problem' },
                                      { linter:   'FakeLinter',
                                        location: "#{@a_feature_file}:1",
                                        problem:  'FakeLinter problem' }])
    end

  end

  context 'with neither model trees or file paths' do

    before(:each) do
      linting_options.delete(:model_trees)
      linting_options.delete(:file_paths)
    end

    it 'models the current directory' do
      test_dir = create_directory
      File.write("#{test_dir}/test_feature.feature", 'Feature:')

      Dir.chdir(test_dir) do
        @results = subject.lint(**linting_options)
      end

      # There should be 3 models to lint: the directory, the feature file, and the feature
      expect(@results.count).to eq(3)
    end

  end

  it 'uses evey linter provided' do
    linting_options[:linters] = [generate_fake_linter(name: 'FakeLinter1'),
                                 generate_fake_linter(name: 'FakeLinter2')]

    results = subject.lint(**linting_options)

    expect(results).to match_array([{ linter:   'FakeLinter1',
                                      location: 'path_to_file:1',
                                      problem:  'FakeLinter1 problem' },
                                    { linter:   'FakeLinter2',
                                      location: 'path_to_file:1',
                                      problem:  'FakeLinter2 problem' }])
  end

  it 'uses all registered linters if none are provided', :linter_registration do
    CukeLinter.clear_registered_linters
    CukeLinter.register_linter(linter: generate_fake_linter(name: 'FakeLinter1'), name: 'FakeLinter1')
    CukeLinter.register_linter(linter: generate_fake_linter(name: 'FakeLinter2'), name: 'FakeLinter2')
    CukeLinter.register_linter(linter: generate_fake_linter(name: 'FakeLinter3'), name: 'FakeLinter3')

    begin
      linting_options.delete(:linters)
      results = subject.lint(**linting_options)

      expect(results).to match_array([{ linter:   'FakeLinter1',
                                        location: 'path_to_file:1',
                                        problem:  'FakeLinter1 problem' },
                                      { linter:   'FakeLinter2',
                                        location: 'path_to_file:1',
                                        problem:  'FakeLinter2 problem' },
                                      { linter:   'FakeLinter3',
                                        location: 'path_to_file:1',
                                        problem:  'FakeLinter3 problem' }])
    ensure
      CukeLinter.reset_linters
    end
  end

  it 'includes the name of the linter in the linting data' do
    linting_options[:linters] = [generate_fake_linter(name: 'FakeLinter1'),
                                 generate_fake_linter(name: 'FakeLinter2')]

    results = subject.lint(**linting_options)

    expect(results).to match_array([{ linter:   'FakeLinter1',
                                      location: 'path_to_file:1',
                                      problem:  'FakeLinter1 problem' },
                                    { linter:   'FakeLinter2',
                                      location: 'path_to_file:1',
                                      problem:  'FakeLinter2 problem' }])
  end

  it 'has a default set of registered linters' do
    subject.reset_linters

    default_linter_classes = %w[BackgroundDoesMoreThanSetupLinter
                                ElementWithCommonTagsLinter
                                ElementWithDuplicateTagsLinter
                                ElementWithTooManyTagsLinter
                                ExampleWithoutNameLinter
                                FeatureFileWithInvalidNameLinter
                                FeatureFileWithMismatchedNameLinter
                                FeatureWithTooManyDifferentTagsLinter
                                FeatureWithoutDescriptionLinter
                                FeatureWithoutNameLinter
                                FeatureWithoutScenariosLinter
                                OutlineWithSingleExampleRowLinter
                                SingleTestBackgroundLinter
                                StepWithEndPeriodLinter
                                StepWithTooManyCharactersLinter
                                TestShouldUseBackgroundLinter
                                TestWithActionStepAsFinalStepLinter
                                TestWithBadNameLinter
                                TestWithNoActionStepLinter
                                TestWithNoNameLinter
                                TestWithNoVerificationStepLinter
                                TestWithSetupStepAfterActionStepLinter
                                TestWithSetupStepAfterVerificationStepLinter
                                TestWithSetupStepAsFinalStepLinter
                                TestWithTooManyStepsLinter]

    expect(subject.registered_linters.keys).to eq(default_linter_classes)

    default_linter_classes.each do |clazz|
      expect(subject.registered_linters[clazz]).to be_a(CukeLinter.const_get(clazz))

    end
  end

  it 'returns to its default set of linters after being reset' do
    CukeLinter.reset_linters

    original_names        = CukeLinter.registered_linters.keys
    original_linter_types = CukeLinter.registered_linters.values.map(&:class)
    new_linter            = generate_fake_linter

    CukeLinter.register_linter(linter: new_linter, name: 'FakeLinter')
    expect(CukeLinter.registered_linters.keys).to include('FakeLinter')
    CukeLinter.reset_linters

    expect(CukeLinter.registered_linters.keys).to eq(original_names)
    expect(CukeLinter.registered_linters.values.map(&:class)).to eq(original_linter_types)
  end

  # To protect against someone modifying them
  it 'does not reuse the old linting objects when resetting to the default linters' do
    original_linter_ids = CukeLinter.registered_linters.values.map(&:object_id)

    CukeLinter.reset_linters

    expect(CukeLinter.registered_linters.values.map(&:object_id)).to_not match_array(original_linter_ids)
  end

  it 'can handle a mixture of problematic and non-problematic models' do
    linting_options[:linters] = [generate_fake_linter(finds_problems: true),
                                 generate_fake_linter(finds_problems: false)]

    expect { subject.lint(**linting_options) }.to_not raise_error
  end

end
