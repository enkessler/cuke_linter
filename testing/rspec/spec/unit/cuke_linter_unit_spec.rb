RSpec.describe 'the gem' do

  let(:lib_folder) { "#{@root_dir}/lib" }
  let(:exe_folder) { "#{@root_dir}/exe" }
  let(:features_folder) { "#{@root_dir}/testing/cucumber/features" }

  before(:all) do
    @root_dir = "#{__dir__}/../../../.."

    # Doing this as a one time hook instead of using `let` in order to reduce I/O time during testing.
    @gemspec = eval(File.read("#{@root_dir}/cuke_linter.gemspec"))
  end


  it 'has an executable' do
    expect(@gemspec.executables).to eq(['cuke_linter'])
  end

  it 'validates cleanly' do
    in_stream = StringIO.new
    out_stream = StringIO.new
    error_stream = StringIO.new
    mock_ui = Gem::StreamUI.new(in_stream, out_stream, error_stream)

    Gem::DefaultUserInteraction.use_ui(mock_ui) { @gemspec.validate }

    expect(error_stream.string).to_not match(/warn/i)
  end

  it 'is named correctly' do
    expect(@gemspec.name).to eq('cuke_linter')
  end

  it 'runs on Ruby' do
    expect(@gemspec.platform).to eq(Gem::Platform::RUBY)
  end

  it 'exposes its "lib" folder' do
    expect(@gemspec.require_paths).to match_array(['lib'])
  end

  it 'has a version' do
    expect(@gemspec.version.version).to eq(CukeLinter::VERSION)
  end

  it 'lists major authors' do
    expect(@gemspec.authors).to match_array(['Eric Kessler'])
  end

  it 'has contact emails for active maintainers' do
    expect(@gemspec.email).to match_array(['morrow748@gmail.com'])
  end

  it 'has a homepage' do
    expect(@gemspec.homepage).to eq('https://github.com/enkessler/cuke_linter')
  end

  it 'has a summary' do
    text = <<-TEXT
      Lints feature files used by Cucumber and other similar frameworks.
    TEXT
           .strip.delete("\n").squeeze(' ')

    expect(@gemspec.summary).to eq(text)
  end

  it 'has a description' do
    text = <<-TEXT
      This gem provides linters for detecting common 'smells' in `.feature` files. In addition to
      the provided linters, custom linters can be made in order to create custom linting rules.
    TEXT
           .strip.delete("\n").squeeze(' ')

    expect(@gemspec.description).to eq(text)
  end


  describe 'license' do

    before(:all) do
      # Doing this as a one time hook instead of using `let` in order to reduce I/O time during testing.
      @license_text = File.read("#{@root_dir}/LICENSE.txt")
    end

    it 'has a current license' do
      expect(@license_text).to match(/Copyright.*2018-#{Time.now.year}/)
    end

    it 'uses the MIT license' do
      expect(@license_text).to include('MIT License')
      expect(@gemspec.licenses).to match_array(['MIT'])
    end

  end


  describe 'metadata' do

    it 'links to the changelog' do
      expect(@gemspec.metadata['changelog_uri']).to eq('https://github.com/enkessler/cuke_linter/blob/master/CHANGELOG.md')
    end

    it 'links to the known issues/bugs' do
      expect(@gemspec.metadata['bug_tracker_uri']).to eq('https://github.com/enkessler/cuke_linter/issues')
    end

    it 'links to the source code' do
      expect(@gemspec.metadata['source_code_uri']).to eq('https://github.com/enkessler/cuke_linter')
    end

    it 'links to the home page of the project' do
      expect(@gemspec.metadata['homepage_uri']).to eq(@gemspec.homepage)
    end

    it 'links to the gem documentation' do
      expect(@gemspec.metadata['documentation_uri']).to eq('https://www.rubydoc.info/gems/cuke_linter')
    end

    it 'has two-factor authentication enabled' do
      expect(@gemspec.metadata['rubygems_mfa_required']).to eq('true')
    end

  end


  describe 'included files' do

    # This test modifies the files present in the gem and so it can interfere with other gem
    # related tests when being run in parallel.
    it 'does not include files that are not source controlled' do
      bad_file_1 = File.absolute_path("#{lib_folder}/foo.txt")
      bad_file_2 = File.absolute_path("#{exe_folder}/foo.txt")
      bad_file_3 = File.absolute_path("#{features_folder}/foo.txt")

      begin
        FileUtils.touch(bad_file_1)
        FileUtils.touch(bad_file_2)
        FileUtils.touch(bad_file_3)

        gem_files = @gemspec.files.map { |file| File.absolute_path(file) }

        expect(gem_files).to_not include(bad_file_1, bad_file_2, bad_file_3)
      ensure
        FileUtils.rm([bad_file_1, bad_file_2, bad_file_3])
      end
    end

    it 'does not include just any source controlled file' do
      some_files_not_to_include = ['Gemfile', 'Rakefile']

      some_files_not_to_include.each do |file|
        expect(@gemspec.files).to_not include(file)
      end
    end

    it 'includes all of the library files' do
      retries = 0

      # When run in parallel, this test can fail due to race conditions with other tests that modify the files present
      # in the gem. It's easier to just retry this test if it fails than to try and isolate the other offending tests.
      begin
        lib_files = Dir.chdir(@root_dir) do
          Dir.glob('lib/**/*').reject { |file| File.directory?(file) }
        end

        expect(@gemspec.files).to include(*lib_files)
      rescue RSpec::Expectations::ExpectationNotMetError => e
        raise e if retries > 2

        retries += 1
        sleep 2
        retry
      end
    end

    it 'includes all of the executable files' do
      retries = 0

      # When run in parallel, this test can fail due to race conditions with other tests that modify the files present
      # in the gem. It's easier to just retry this test if it fails than to try and isolate the other offending tests.
      begin
        exe_files = Dir.chdir(@root_dir) do
          Dir.glob('exe/**/*').reject { |file| File.directory?(file) }
        end

        expect(@gemspec.files).to include(*exe_files)
      rescue RSpec::Expectations::ExpectationNotMetError => e
        raise e if retries > 2

        retries += 1
        sleep 2
        retry
      end
    end

    it 'includes all of the documentation files' do
      retries = 0

      # When run in parallel, this test can fail due to race conditions with other tests that modify the files present
      # in the gem. It's easier to just retry this test if it fails than to try and isolate the other offending tests.
      begin
        feature_files = Dir.chdir(@root_dir) do
          Dir.glob('testing/cucumber/features/**/*').reject { |file| File.directory?(file) }
        end

        expect(@gemspec.files).to include(*feature_files)
      rescue RSpec::Expectations::ExpectationNotMetError => e
        raise e if retries > 2

        retries += 1
        sleep 2
        retry
      end
    end

    it 'includes the README file' do
      readme_file = 'README.md'

      expect(@gemspec.files).to include(readme_file)
    end

    it 'includes the license file' do
      license_file = 'LICENSE.txt'

      expect(@gemspec.files).to include(license_file)
    end

    it 'includes the CHANGELOG file' do
      changelog_file = 'CHANGELOG.md'

      expect(@gemspec.files).to include(changelog_file)
    end

    it 'includes the gemspec file' do
      gemspec_file = 'cuke_linter.gemspec'

      expect(@gemspec.files).to include(gemspec_file)
    end

  end


  describe 'dependencies' do

    it 'works with Ruby 2 and 3' do
      ruby_version_limits = @gemspec.required_ruby_version.requirements.map(&:join)

      expect(ruby_version_limits).to match_array(['>=2.1', '<4.0'])
    end

    it 'works with CukeModeler 1-3' do
      cuke_modeler_version_limits = @gemspec.dependencies
                                            .find do |dependency|
                                              (dependency.type == :runtime) &&
                                                (dependency.name == 'cuke_modeler')
                                            end
                                            .requirement.requirements.map(&:join)

      expect(cuke_modeler_version_limits).to match_array(['>=1.5', '<4.0'])
    end

  end

end


RSpec.describe CukeLinter do

  it 'has a version number' do
    expect(CukeLinter::VERSION).not_to be nil
  end

  it "has a default keyword for 'Given'" do
    expect(CukeLinter::DEFAULT_GIVEN_KEYWORD).to eq('Given')
  end

  it "has a default keyword for 'When'" do
    expect(CukeLinter::DEFAULT_WHEN_KEYWORD).to eq('When')
  end

  it "has a default keyword for 'Then'" do
    expect(CukeLinter::DEFAULT_THEN_KEYWORD).to eq('Then')
  end

  it 'can lint' do
    expect(CukeLinter).to respond_to(:lint)
  end

  it 'lints using a set of model trees, file paths, linters, and formatters (all of which are optional)' do
    expect(CukeLinter.method(:lint).arity).to eq(-1)
    expect(CukeLinter.method(:lint).parameters).to match_array([%i[key model_trees],
                                                                %i[key linters],
                                                                %i[key formatters],
                                                                %i[key file_paths]])
  end

  it 'can register a linter' do
    expect(CukeLinter).to respond_to(:register_linter)
  end

  it 'can unregister a linter' do
    expect(CukeLinter).to respond_to(:unregister_linter)
  end

  it 'registers a linter by name' do
    expect(CukeLinter.method(:register_linter).arity).to eq(1)
    expect(CukeLinter.method(:register_linter).parameters).to match_array([%i[keyreq linter],
                                                                           %i[keyreq name]])
  end

  it 'unregisters a linter by name' do
    expect(CukeLinter.method(:unregister_linter).arity).to eq(1)
    expect(CukeLinter.method(:unregister_linter).parameters).to match_array([%i[req name]])
  end

  it 'knows its currently registered linters' do
    expect(CukeLinter).to respond_to(:registered_linters)
  end

  it 'correctly registers, unregisters, and tracks linters', :linter_registration do
    CukeLinter.clear_registered_linters
    CukeLinter.register_linter(name: 'foo', linter: :linter_1)
    CukeLinter.register_linter(name: 'bar', linter: :linter_2)
    CukeLinter.register_linter(name: 'baz', linter: :linter_3)

    CukeLinter.unregister_linter('bar')

    expect(CukeLinter.registered_linters).to eq('foo' => :linter_1,
                                                'baz' => :linter_3)
  end

  it 'can clear all of its currently registered linters', :linter_registration do
    expect(CukeLinter).to respond_to(:clear_registered_linters)

    CukeLinter.register_linter(name: 'some_linter', linter: :the_linter)
    CukeLinter.clear_registered_linters

    expect(CukeLinter.registered_linters).to eq({})
  end

  it 'can reset to its default set of linters' do
    expect(CukeLinter).to respond_to(:reset_linters)
  end

  describe 'configuration' do

    it 'can load a configuration' do
      expect(CukeLinter).to respond_to(:load_configuration)
    end

    it 'is configured optionally via a file or a directly provided configuration' do
      expect(CukeLinter.method(:load_configuration).arity).to eq(-1)
      expect(CukeLinter.method(:load_configuration).parameters).to match_array([%i[key config_file_path],
                                                                                %i[key config]])
    end

  end

end
