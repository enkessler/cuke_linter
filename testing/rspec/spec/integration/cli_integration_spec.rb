require_relative '../../../../environments/rspec_env'
require 'open3'


RSpec.describe 'the Command Line Interface' do

  let(:executable_directory) { "#{PROJECT_ROOT}/exe" }
  let(:executable_name) { 'cuke_linter' }
  let(:flag) { '' }
  let(:command) { "bundle exec ruby ./#{executable_name} #{flag}" }
  let(:results) { std_out, std_err, status = [nil, nil, nil]

                  Dir.chdir(executable_directory) do
                    std_out, std_err, status = Open3.capture3(command)
                  end

                  { std_out: std_out, std_err: std_err, status: status } }


  it 'can run cleanly by default' do
    expect(results[:status].exitstatus).to eq(0)
  end


  describe 'option flags' do

    context 'with a help flag' do
      ['-h', '--help'].each do |help_flag|

        let(:flag) { help_flag }

        it "'#{help_flag}' displays the help text" do
          expect(results[:std_out]).to eq(['Usage: cuke_linter [options]',
                                           '    -h, --help           Display the help that you are reading now.',
                                           '    -v, --version        Display the version of the gem being used.',
                                           ''].join("\n"))
        end

        it 'exits cleanly' do
          expect(results[:status].exitstatus).to eq(0)
        end

      end
    end

    context 'with a version flag' do
      ['-v', '--version'].each do |version_flag|

        let(:flag) { version_flag }

        it "'#{version_flag}' displays the version being used" do
          expect(results[:std_out]).to eq("#{CukeLinter::VERSION}\n")
        end

        it 'exits cleanly' do
          expect(results[:status].exitstatus).to eq(0)
        end

      end
    end

    context 'with an invalid flag' do

      let(:flag) { '--not_a_real_flag' }

      it 'complains about the invalid flag' do
        expect(results[:std_out]).to include("invalid option: #{flag}")
      end

      it 'displays the help text' do
        expect(results[:std_out]).to include(['Usage: cuke_linter [options]',
                                              '    -h, --help           Display the help that you are reading now.',
                                              '    -v, --version        Display the version of the gem being used.'].join("\n"))
      end

      it 'exits with an error' do
        expect(results[:status].exitstatus).to eq(1)
      end

    end

  end

end
