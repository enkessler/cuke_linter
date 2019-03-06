require_relative '../../../../../environments/rspec_env'


RSpec.describe CukeLinter::PrettyFormatter do

  it_should_behave_like 'a formatter at the unit level'


  it 'formats linting data as pretty text' do
    linting_data = [{ linter:   'SomeLinter',
                      problem:  'Some problem',
                      location: 'path/to/the_file:1' },
                    { linter:   'SomeOtherLinter',
                      problem:  'Some other problem',
                      location: 'path/to/the_file:1' }]

    results = subject.format(linting_data)

    expect(results).to eq(['SomeLinter',
                           '  Some problem',
                           '    path/to/the_file:1',
                           'SomeOtherLinter',
                           '  Some other problem',
                           '    path/to/the_file:1',
                           '',
                           '2 issues found'].join("\n"))
  end

  it 'groups data by linter and problem' do
    linting_data = [{ linter:   'SomeLinter',
                      problem:  'Some problem',
                      location: 'path/to/the_file:1' },
                    { linter:   'SomeOtherLinter',
                      problem:  'Some other problem',
                      location: 'path/to/the_file:1' },
                    { linter:   'SomeLinter',
                      problem:  'Some problem',
                      location: 'path/to/the_file:11' }]

    results = subject.format(linting_data)

    expect(results).to eq(['SomeLinter',
                           '  Some problem',
                           '    path/to/the_file:1',
                           '    path/to/the_file:11',
                           'SomeOtherLinter',
                           '  Some other problem',
                           '    path/to/the_file:1',
                           '',
                           '3 issues found'].join("\n"))
  end

  it 'orders violations by line number' do
    linting_data = [{ linter:   'SomeLinter',
                      problem:  'Some problem',
                      location: 'path/to/the_file:2' },
                    { linter:   'SomeLinter',
                      problem:  'Some problem',
                      location: 'path/to/the_file:3' },
                    { linter:   'SomeLinter',
                      problem:  'Some problem',
                      location: 'path/to/the_file:3' },
                    { linter:   'SomeLinter',
                      problem:  'Some problem',
                      location: 'path/to/the_file:1' }]

    results = subject.format(linting_data)

    expect(results).to eq(['SomeLinter',
                           '  Some problem',
                           '    path/to/the_file:1',
                           '    path/to/the_file:2',
                           '    path/to/the_file:3',
                           '    path/to/the_file:3',
                           '',
                           '4 issues found'].join("\n"))
  end

end
