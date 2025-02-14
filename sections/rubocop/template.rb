source_paths.unshift(File.dirname(__FILE__))

insert_into_file 'Gemfile', after: /^group :development, :test do\n/ do
  <<-GEMS
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  GEMS
end

unless options.skip_test?
  insert_into_file 'Gemfile', after: /^group :development, :test do\n/ do
    <<-GEMS
    gem 'rubocop-rspec'
    gem 'rubocop-factory_bot'
    GEMS
  end
end

run 'bundle install'

template '.rubocop.yml', force: true
template '.rubocop-custom.yml'
template '.rubocop-disabled.yml'

gsub_file 'Gemfile', '# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]', ''
gsub_file 'Gemfile', 'gem "rubocop-rails-omakase", require: false', ''
gsub_file 'config/environments/development.rb',
          '# config.generators.apply_rubocop_autocorrect_after_generate!',
          'config.generators.apply_rubocop_autocorrect_after_generate!'

run 'bin/rubocop -A --fail-level=E'

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m 'Install and configure `rubocop` code linter'"
end
