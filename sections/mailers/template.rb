insert_into_file 'Gemfile', after: /^group :development do\n/ do
  <<-GEMS
  gem 'letter_opener_web'
  GEMS
end

inject_into_file 'config/environments/development.rb', before: /^end/ do
  <<-RUBY
    config.action_mailer.default_url_options = {
      host: 'http://localhost', port: ENV.fetch('PORT', 3000)
    }
    config.action_mailer.delivery_method = :letter_opener_web
    config.action_mailer.perform_deliveries = true
  RUBY
end

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m 'Configure mailer in development with `letter_opener_web`'"
end
