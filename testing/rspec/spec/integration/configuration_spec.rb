require_relative '../../../../environments/rspec_env'

RSpec.describe CukeLinter do

  describe 'configuration' do

    describe 'blanket linters' do

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

    describe 'targeted linters' do

      before(:all) do
        @targeted_linter_class             = CukeLinter::LinterFactory.generate_fake_linter_class(class_name: 'ATargetedLinterClass', name: 'ATargetedLinter')
        @another_targeted_linter_class     = CukeLinter::LinterFactory.generate_fake_linter_class(class_name: 'AnotherTargetedLinterClass', name: 'AnotherTargetedLinter')
        @yet_another_targeted_linter_class = CukeLinter::LinterFactory.generate_fake_linter_class(class_name: 'YetAnotherTargetedLinterClass', name: 'YetAnotherTargetedLinter')

        @a_non_nested_targeted_linter_class       = CukeLinter::LinterFactory.generate_fake_linter_class(module_name: nil, class_name: 'ANonNestedTargetedLinterClass', name: 'ANonNestedTargetedLinter')
        @another_non_nested_targeted_linter_class = CukeLinter::LinterFactory.generate_fake_linter_class(module_name: nil, class_name: 'AnotherNonNestedTargetedLinterClass', name: 'AnotherNonNestedTargetedLinter')

        @a_nested_targeted_linter_class       = CukeLinter::LinterFactory.generate_fake_linter_class(module_name: 'Foo', class_name: 'ANestedTargetedLinterClass', name: 'ANestedTargetedLinter')
        @another_nested_targeted_linter_class = CukeLinter::LinterFactory.generate_fake_linter_class(module_name: 'Foo', class_name: 'AnotherNestedTargetedLinterClass', name: 'AnotherNestedTargetedLinter')
      end


      let(:linter_name) { 'ATargetedLinter' }
      let(:another_linter_name) { 'AnotherTargetedLinter' }
      let(:yet_another_linter_name) { 'YetAnotherTargetedLinter' }

      let(:non_nested_linter_name) { 'ANonNestedTargetedLinter' }
      let(:another_non_nested_linter_name) { 'AnotherNonNestedTargetedLinter' }
      let(:nested_linter_name) { 'ANestedTargetedLinter' }
      let(:another_nested_linter_name) { 'AnotherNestedTargetedLinter' }

      let(:linter_class_name) { 'ATargetedLinterClass' }
      let(:another_linter_class_name) { 'AnotherTargetedLinterClass' }
      let(:yet_another_linter_class_name) { 'YetAnotherTargetedLinterClass' }
      let(:non_nested_linter_class_name) { 'ANonNestedTargetedLinterClass' }
      let(:another_non_nested_linter_class_name) { 'AnotherNonNestedTargetedLinterClass' }
      let(:nested_linter_class_name) { 'Foo::ANestedTargetedLinterClass' }
      let(:another_nested_linter_class_name) { 'Foo::AnotherNestedTargetedLinterClass' }

      let(:targeted_linter) { @targeted_linter_class.new }
      let(:another_targeted_linter) { @another_targeted_linter_class.new }
      let(:yet_another_targeted_linter) { @yet_another_targeted_linter_class.new }
      let(:non_nested_targeted_linter) { @a_non_nested_targeted_linter_class.new }
      let(:nested_targeted_linter) { @a_nested_targeted_linter_class.new }

      let(:test_linters) { [targeted_linter] }
      let(:test_linter_names) { [linter_name] }
      let(:test_formatters) { [[CukeLinter::FormatterFactory.generate_fake_formatter, "#{CukeLinter::FileHelper::create_directory}/junk_output_file.txt"]] }
      let(:test_model_trees) { [CukeModeler::FeatureFile.new(linted_file)] }

      let(:test_directory) { CukeLinter::FileHelper.create_directory }
      let(:linted_file) { CukeLinter::FileHelper.create_file(directory: test_directory,
                                                             extension: '.feature',
                                                             text:      file_text) }


      [:provided, :registered].each do |linter_type|

        context "using #{linter_type} linters" do

          if linter_type == :provided
            let(:linting_options) { { model_trees: test_model_trees, linters: test_linters, formatters: test_formatters } }
          else
            let(:linting_options) { { model_trees: test_model_trees, formatters: test_formatters } }

            before(:each) do
              subject.clear_registered_linters

              test_linters.each_with_index { |linter, index| subject.register_linter(linter: linter, name: test_linter_names[index]) }
            end
          end


          context 'with non-nested class names' do

            let(:test_linters) { [non_nested_targeted_linter] }
            let(:test_linter_names) { [non_nested_linter_name] }

            let(:file_text) { "Feature:

                                 # cuke_linter:disable #{non_nested_linter_class_name}
                                 # cuke_linter:enable #{another_non_nested_linter_class_name}
                                 Scenario:" }


            it 'handles the directives correctly' do
              results = subject.lint(linting_options)

              expect(results).to match_array([{ linter: non_nested_linter_name, location: linted_file, problem: "#{non_nested_linter_name} problem" },
                                              { linter: non_nested_linter_name, location: "#{linted_file}:1", problem: "#{non_nested_linter_name} problem" },
                                              { linter: another_non_nested_linter_name, location: "#{linted_file}:5", problem: "#{another_non_nested_linter_name} problem" }])
            end

          end

          context 'with nested class names' do

            let(:test_linters) { [nested_targeted_linter] }
            let(:test_linter_names) { [nested_linter_name] }

            let(:file_text) { "Feature:

                                 # cuke_linter:disable #{nested_linter_class_name}
                                 # cuke_linter:enable #{another_nested_linter_class_name}
                                 Scenario:" }


            it 'handles the directives correctly' do
              results = subject.lint(linting_options)

              expect(results).to match_array([{ linter: nested_linter_name, location: linted_file, problem: "#{nested_linter_name} problem" },
                                              { linter: nested_linter_name, location: "#{linted_file}:1", problem: "#{nested_linter_name} problem" },
                                              { linter: another_nested_linter_name, location: "#{linted_file}:5", problem: "#{another_nested_linter_name} problem" }])
            end

          end

          context 'with multiple linters in the directive' do

            let(:commas_text) { "Feature:

                                   # cuke_linter:disable #{linter_class_name}, #{another_linter_class_name}, #{yet_another_linter_class_name}
                                   Scenario:" }
            let(:commas_file) { CukeLinter::FileHelper.create_file(directory: test_directory,
                                                                   extension: '.feature',
                                                                   text:      commas_text,
                                                                   name:      'commas_text') }

            let(:spaces_text) { "Feature:

                                   # cuke_linter:disable #{linter_class_name} #{another_linter_class_name} #{yet_another_linter_class_name}
                                   Scenario:" }
            let(:spaces_file) { CukeLinter::FileHelper.create_file(directory: test_directory,
                                                                   extension: '.feature',
                                                                   text:      spaces_text,
                                                                   name:      'spaces_text') }

            let(:test_model_trees) { [CukeModeler::FeatureFile.new(commas_file),
                                      CukeModeler::FeatureFile.new(spaces_file)] }

            let(:test_linters) { [targeted_linter, another_targeted_linter, yet_another_targeted_linter] }
            let(:test_linter_names) { [linter_name, another_linter_name, yet_another_linter_name] }


            it 'handles the directives correctly' do
              results = subject.lint(linting_options)

              expect(results).to match_array([{ linter: linter_name, location: spaces_file, problem: "#{linter_name} problem" },
                                              { linter: linter_name, location: "#{spaces_file}:1", problem: "#{linter_name} problem" },
                                              { linter: another_linter_name, location: spaces_file, problem: "#{another_linter_name} problem" },
                                              { linter: another_linter_name, location: "#{spaces_file}:1", problem: "#{another_linter_name} problem" },
                                              { linter: yet_another_linter_name, location: spaces_file, problem: "#{yet_another_linter_name} problem" },
                                              { linter: yet_another_linter_name, location: "#{spaces_file}:1", problem: "#{yet_another_linter_name} problem" },

                                              { linter: linter_name, location: commas_file, problem: "#{linter_name} problem" },
                                              { linter: linter_name, location: "#{commas_file}:1", problem: "#{linter_name} problem" },
                                              { linter: another_linter_name, location: commas_file, problem: "#{another_linter_name} problem" },
                                              { linter: another_linter_name, location: "#{commas_file}:1", problem: "#{another_linter_name} problem" },
                                              { linter: yet_another_linter_name, location: commas_file, problem: "#{yet_another_linter_name} problem" },
                                              { linter: yet_another_linter_name, location: "#{commas_file}:1", problem: "#{yet_another_linter_name} problem" }])
            end

          end

          context 'with multiple files' do

            let(:modified_text) { "Feature:

                                     # cuke_linter:disable #{linter_class_name}
                                     Scenario:" }
            let(:modified_file) { CukeLinter::FileHelper.create_file(directory: test_directory,
                                                                     extension: '.feature',
                                                                     text:      modified_text) }
            let(:unmodified_text) { "Feature:

                                       Scenario:" }
            let(:unmodified_file) { CukeLinter::FileHelper.create_file(directory: test_directory,
                                                                       extension: '.feature',
                                                                       text:      unmodified_text) }

            let(:test_model_trees) { [CukeModeler::FeatureFile.new(modified_file),
                                      CukeModeler::FeatureFile.new(unmodified_file)] }

            it 'does not use targeted linting changes outside of the file in which they occur' do
              results = subject.lint(linting_options)

              expect(results).to match_array([{ linter: linter_name, location: modified_file, problem: "#{linter_name} problem" },
                                              { linter: linter_name, location: "#{modified_file}:1", problem: "#{linter_name} problem" },
                                              { linter: linter_name, location: unmodified_file, problem: "#{linter_name} problem" },
                                              { linter: linter_name, location: "#{unmodified_file}:1", problem: "#{linter_name} problem" },
                                              { linter: linter_name, location: "#{unmodified_file}:3", problem: "#{linter_name} problem" }])
            end

          end

          context 'with other comments in the file' do

            let(:file_text) { "# I'm just a comment
                                   Feature:

                                     # cuke_linter:disable #{linter_class_name}
                                     #Me too
                                     Scenario:" }


            it 'handles the directive correctly' do
              results = subject.lint(linting_options)

              expect(results).to match_array([{ linter: linter_name, location: linted_file, problem: "#{linter_name} problem" },
                                              { linter: linter_name, location: "#{linted_file}:2", problem: "#{linter_name} problem" }])
            end

          end

          context 'with varying whitespace' do

            let(:extra_whitespace_text) { "Feature:

                                             #      cuke_linter:disable       #{linter_class_name}
                                             Scenario:" }
            let(:extra_whitespace_file) { CukeLinter::FileHelper.create_file(directory: test_directory,
                                                                             extension: '.feature',
                                                                             text:      extra_whitespace_text) }
            let(:minimal_whitespace_text) { "Feature:

                                               #cuke_linter:disable #{linter_class_name}
                                               Scenario:" }
            let(:minimal_whitespace_file) { CukeLinter::FileHelper.create_file(directory: test_directory,
                                                                               extension: '.feature',
                                                                               text:      minimal_whitespace_text) }

            let(:test_model_trees) { [CukeModeler::FeatureFile.new(extra_whitespace_file),
                                      CukeModeler::FeatureFile.new(minimal_whitespace_file)] }


            it 'handles the directives correctly' do
              results = subject.lint(linting_options)

              expect(results).to match_array([{ linter: linter_name, location: extra_whitespace_file, problem: "#{linter_name} problem" },
                                              { linter: linter_name, location: "#{extra_whitespace_file}:1", problem: "#{linter_name} problem" },
                                              { linter: linter_name, location: minimal_whitespace_file, problem: "#{linter_name} problem" },
                                              { linter: linter_name, location: "#{minimal_whitespace_file}:1", problem: "#{linter_name} problem" }])
            end


            context 'and multiple targeted linters' do

              let(:spaced_commas_text) { "Feature:

                                            # cuke_linter:disable #{linter_class_name}    ,    #{another_linter_class_name} , #{yet_another_linter_class_name}
                                            Scenario:" }
              let(:spaced_commas_file) { CukeLinter::FileHelper.create_file(directory: test_directory,
                                                                            extension: '.feature',
                                                                            text:      spaced_commas_text,
                                                                            name:      'spaced_commas_text') }

              let(:compact_commas_text) { "Feature:

                                             # cuke_linter:disable #{linter_class_name},#{another_linter_class_name},#{yet_another_linter_class_name}
                                             Scenario:" }
              let(:compact_commas_file) { CukeLinter::FileHelper.create_file(directory: test_directory,
                                                                             extension: '.feature',
                                                                             text:      compact_commas_text,
                                                                             name:      'compact_commas_text') }

              let(:spaced_space_text) { "Feature:

                                           # cuke_linter:disable #{linter_class_name}        #{another_linter_class_name}  #{yet_another_linter_class_name}
                                           Scenario:" }
              let(:spaced_space_file) { CukeLinter::FileHelper.create_file(directory: test_directory,
                                                                           extension: '.feature',
                                                                           text:      spaced_space_text,
                                                                           name:      'spaced_space_text') }

              let(:compact_space_text) { "Feature:

                                            # cuke_linter:disable #{linter_class_name} #{another_linter_class_name} #{yet_another_linter_class_name}
                                            Scenario:" }
              let(:compact_space_file) { CukeLinter::FileHelper.create_file(directory: test_directory,
                                                                            extension: '.feature',
                                                                            text:      compact_space_text,
                                                                            name:      'compact_space_text') }

              let(:test_model_trees) { [CukeModeler::FeatureFile.new(spaced_commas_file),
                                        CukeModeler::FeatureFile.new(compact_commas_file),
                                        CukeModeler::FeatureFile.new(spaced_space_file),
                                        CukeModeler::FeatureFile.new(compact_space_file)] }

              let(:test_linters) { [targeted_linter, another_targeted_linter, yet_another_targeted_linter] }
              let(:test_linter_names) { [linter_name, another_linter_name, yet_another_linter_name] }


              it 'handles the directives correctly' do
                results = subject.lint(linting_options)

                expect(results).to match_array([{ linter: linter_name, location: spaced_commas_file, problem: "#{linter_name} problem" },
                                                { linter: linter_name, location: "#{spaced_commas_file}:1", problem: "#{linter_name} problem" },
                                                { linter: another_linter_name, location: spaced_commas_file, problem: "#{another_linter_name} problem" },
                                                { linter: another_linter_name, location: "#{spaced_commas_file}:1", problem: "#{another_linter_name} problem" },
                                                { linter: yet_another_linter_name, location: spaced_commas_file, problem: "#{yet_another_linter_name} problem" },
                                                { linter: yet_another_linter_name, location: "#{spaced_commas_file}:1", problem: "#{yet_another_linter_name} problem" },

                                                { linter: linter_name, location: compact_commas_file, problem: "#{linter_name} problem" },
                                                { linter: linter_name, location: "#{compact_commas_file}:1", problem: "#{linter_name} problem" },
                                                { linter: another_linter_name, location: compact_commas_file, problem: "#{another_linter_name} problem" },
                                                { linter: another_linter_name, location: "#{compact_commas_file}:1", problem: "#{another_linter_name} problem" },
                                                { linter: yet_another_linter_name, location: compact_commas_file, problem: "#{yet_another_linter_name} problem" },
                                                { linter: yet_another_linter_name, location: "#{compact_commas_file}:1", problem: "#{yet_another_linter_name} problem" },

                                                { linter: linter_name, location: spaced_space_file, problem: "#{linter_name} problem" },
                                                { linter: linter_name, location: "#{spaced_space_file}:1", problem: "#{linter_name} problem" },
                                                { linter: another_linter_name, location: spaced_space_file, problem: "#{another_linter_name} problem" },
                                                { linter: another_linter_name, location: "#{spaced_space_file}:1", problem: "#{another_linter_name} problem" },
                                                { linter: yet_another_linter_name, location: spaced_space_file, problem: "#{yet_another_linter_name} problem" },
                                                { linter: yet_another_linter_name, location: "#{spaced_space_file}:1", problem: "#{yet_another_linter_name} problem" },

                                                { linter: linter_name, location: compact_space_file, problem: "#{linter_name} problem" },
                                                { linter: linter_name, location: "#{compact_space_file}:1", problem: "#{linter_name} problem" },
                                                { linter: another_linter_name, location: compact_space_file, problem: "#{another_linter_name} problem" },
                                                { linter: another_linter_name, location: "#{compact_space_file}:1", problem: "#{another_linter_name} problem" },
                                                { linter: yet_another_linter_name, location: compact_space_file, problem: "#{yet_another_linter_name} problem" },
                                                { linter: yet_another_linter_name, location: "#{compact_space_file}:1", problem: "#{yet_another_linter_name} problem" }])
              end

            end

          end

          context 'with a disabled(i.e. unregistered)/not provided linter' do

            if linter_type == :provided
              before(:each) do
                test_linters.delete(targeted_linter)
              end
            else
              before(:each) do
                subject.unregister_linter(linter_name)
              end
            end


            context 'that is explicitly disabled' do

              # Used so that the linting process is not entirely bypassed due to no other linters being registered/provided
              let(:baseline_linter_name) { 'BaselineLinter' }
              let(:baseline_linter) { CukeLinter::LinterFactory.generate_fake_linter(name: baseline_linter_name) }

              let(:test_linters) { [baseline_linter, targeted_linter] }
              let(:test_linter_names) { [baseline_linter_name, linter_name] }


              let(:file_text) { "Feature:

                                   # cuke_linter:disable #{linter_class_name}
                                   Scenario:" }

              let(:baseline_linter_results) { [{ linter: baseline_linter_name, location: linted_file, problem: "#{baseline_linter_name} problem" },
                                               { linter: baseline_linter_name, location: "#{linted_file}:1", problem: "#{baseline_linter_name} problem" },
                                               { linter: baseline_linter_name, location: "#{linted_file}:4", problem: "#{baseline_linter_name} problem" }] }


              it 'does not use the linter' do
                results = subject.lint(linting_options)

                expect(results).to match_array(baseline_linter_results + [])
              end


              context 'multiple times' do

                context 'with separate targetings' do

                  let(:file_text) { "Feature:
                                       # cuke_linter:disable #{linter_class_name}
                                       # cuke_linter:disable #{linter_class_name}
                                       Scenario:" }


                  it 'does not use the linter' do
                    results = subject.lint(linting_options)

                    expect(results).to match_array(baseline_linter_results + [])
                  end

                end

                context 'with the same targeting' do

                  let(:file_text) { "Feature:

                                       # cuke_linter:disable #{linter_class_name}, #{linter_class_name}
                                       Scenario:" }

                  it 'does not use the linter' do
                    results = subject.lint(linting_options)

                    expect(results).to match_array(baseline_linter_results + [])
                  end

                end

              end

            end

            context 'that is explicitly enabled' do

              let(:file_text) { "Feature:

                                   # cuke_linter:enable #{linter_class_name}
                                   Scenario:" }

              it 'uses the linter' do
                results = subject.lint(linting_options)

                expect(results).to match_array([{ linter: linter_name, location: "#{linted_file}:4", problem: "#{linter_name} problem" }])
              end

              context 'multiple times' do

                context 'with separate targetings' do

                  it 'uses the linter' do
                    skip('finish me')
                  end

                  it 'does not include redundant linting results' do
                    skip('finish me')
                  end

                end

                context 'with the same targeting' do

                  it 'uses the linter' do
                    skip('finish me')
                  end

                  it 'does not include redundant linting results' do
                    skip('finish me')
                  end

                end

              end

              context 'and then re-disabled' do

                it 'ceases using the linter' do
                  skip('finish me')
                end

              end

            end

          end

          context 'with an enabled(i.e. registered)/provided linter' do

            if linter_type == :provided
              before(:each) do
                test_linters << targeted_linter unless test_linters.include?(targeted_linter)
              end
            else
              before(:each) do
                subject.register_linter(linter: targeted_linter, name: linter_name)
              end
            end


            context 'that is explicitly disabled' do

              let(:file_text) { "Feature:

                                   # cuke_linter:disable #{linter_class_name}
                                   Scenario:" }


              it 'does not use the linter' do
                results = subject.lint(linting_options)

                expect(results).to match_array([{ linter: linter_name, location: linted_file, problem: "#{linter_name} problem" },
                                                { linter: linter_name, location: "#{linted_file}:1", problem: "#{linter_name} problem" }])
              end

              context 'multiple times' do

                context 'with separate targetings' do

                  let(:file_text) { "Feature:
                                       # cuke_linter:disable #{linter_class_name}
                                       # cuke_linter:disable #{linter_class_name}
                                       Scenario:" }


                  it 'does not use the linter' do
                    results = subject.lint(linting_options)

                    expect(results).to match_array([{ linter: linter_name, location: linted_file, problem: "#{linter_name} problem" },
                                                    { linter: linter_name, location: "#{linted_file}:1", problem: "#{linter_name} problem" }])
                  end

                end

                context 'with the same targeting' do

                  let(:file_text) { "Feature:

                                       # cuke_linter:disable #{linter_class_name}, #{linter_class_name}
                                       Scenario:" }

                  it 'does not use the linter' do
                    results = subject.lint(linting_options)

                    expect(results).to match_array([{ linter: linter_name, location: linted_file, problem: "#{linter_name} problem" },
                                                    { linter: linter_name, location: "#{linted_file}:1", problem: "#{linter_name} problem" }])
                  end
                end

              end

              context 'and then re-enabled' do

                it 'resumes using the linter' do
                  skip('finish me')
                end

                # Note: only works if the name of the provided/registered linter matches the class name of the dynamic file-scoped linter
                it 'does not include redundant linting results' do
                  skip('finish me')
                end

              end

            end

            context 'that is explicitly enabled' do

              it 'uses the linter' do
                skip('finish me')
              end

              it 'does not include redundant linting results' do
                skip('finish me')
              end

              it 'prefers the provided (or registered) linter over having to make a new one' do
                skip('finish me')
              end


              context 'multiple times' do

                context 'with separate targetings' do

                  it 'uses the linter' do
                    skip('finish me')
                  end

                  it 'does not include redundant linting results' do
                    skip('finish me')
                  end

                end

                context 'with the same targeting' do

                  it 'uses the linter' do
                    skip('finish me')
                  end

                  it 'does not include redundant linting results' do
                    skip('finish me')
                  end

                end

              end

            end

          end

        end

      end

    end

  end

end
