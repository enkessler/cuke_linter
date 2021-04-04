namespace 'cuke_linter' do

  desc 'Check documentation with YARD'
  task :check_documentation do
    puts Rainbow('Checking inline code documentation...').cyan

    output = `yard stats --list-undoc`
    puts output

    # YARD does not do exit codes, so we have to check the output ourselves.
    raise Rainbow('Parts of the gem are undocumented').red unless output =~ /100.00% documented/

    puts Rainbow('All code documented').green
  end

  # NOTE: There are currently no places to host the feature files but these tasks could be useful when there
  # are places again.

  # # Publishes the current feature file documentation to CucumberPro
  # desc 'Publish feature files to CucumberPro'
  # task :publish_to_cucumberpro do
  #   puts "Publishing features to CucumberPro..."
  #   `git push cucumber-pro`
  # end
  #
  # # Publishes the current feature file documentation to all places
  # desc 'Publish feature files to all documentation services'
  # task :publish_features => [:publish_to_cucumberpro]

end
