# ActiveStorage
gem 'active_storage_validations'
rails_command 'active_storage:install'
rails_command 'db:migrate'

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m 'Setup ActiveStorage'"
end
