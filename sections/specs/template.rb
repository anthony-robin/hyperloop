source_paths.unshift(File.dirname(__FILE__))

insert_into_file 'Gemfile', after: /^group :development, :test do\n/ do
  <<-GEMS
  gem 'rspec-rails'
  GEMS
end

if options.skip_system_test?
  gem_group :test do
    gem 'factory_bot_rails'
    gem 'simplecov'
  end
else
  insert_into_file 'Gemfile', after: /^group :test do\n/ do
    <<-GEMS
    gem 'factory_bot_rails'
    gem 'simplecov'
    GEMS
  end
end

run 'bundle install'
run 'bundle binstubs rspec-core'

generate 'rspec:install'
copy_file '.simplecov'
directory 'spec/requests'
copy_file 'spec/support/factory_bot.rb'

if @authentication
  copy_file 'spec/support/authentication.rb'
  copy_file 'spec/factories/users.rb'
end

gsub_file 'spec/spec_helper.rb', /^=(begin|end)/, ''
gsub_file 'spec/rails_helper.rb', "# Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }", "Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }"
uncomment_lines 'spec/rails_helper.rb', /infer_spec_type_from_file_location!/
comment_lines 'spec/spec_helper.rb', /config.profile_examples = 10/

inject_into_file 'spec/rails_helper.rb', after: "RSpec.configure do |config|\n" do
  <<~RUBY
    config.include ActiveSupport::Testing::TimeHelpers

  RUBY
end

unless options.skip_git?
  append_to_file '.gitignore' do
    <<~IGNORE

      # Ignore specs related files and folders
      spec/examples.txt
      coverage/
    IGNORE
  end
end

unless options.skip_docker?
  append_to_file '.dockerignore' do
    <<~IGNORE

      # Ignore specs related files and folders
      /spec/*
      /coverage/*
      /.simplecov
    IGNORE
  end
end

# Cleanup test/ folder
remove_dir 'test'

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m 'Add and configure `rspec` and `simplecov`'"
end
