source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: '.ruby-version'
gem 'rails', '~> 7.1.2'

gem 'action_policy'
gem 'bootsnap', require: false
gem 'dotenv-rails'
gem 'ffaker'
gem 'image_processing'
gem 'importmap-rails'
gem 'jbuilder'
gem 'meta-tags'
gem 'pagy'
gem 'pg'
gem 'puma', '>= 5.0'
gem 'rails-i18n'
gem 'redis'
gem 'simple_form'
gem 'slim-rails'
gem 'solid_queue', github: 'basecamp/solid_queue'
gem 'sorcery'
gem 'sprockets-rails'
gem 'sqlite3', '~> 1.4'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development do
  gem 'annotate'
  gem 'brakeman', require: false
  gem 'bullet'
  gem 'chusaku', require: false
  gem 'letter_opener'
  gem 'ruby-lsp-rails'
  gem 'web-console'
end

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
end
