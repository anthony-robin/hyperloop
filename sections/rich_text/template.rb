# ActionText
generate 'action_text:install'
rails_command 'db:migrate'

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m 'Setup ActionText'"
end
