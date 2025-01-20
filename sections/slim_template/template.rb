gem 'slim-rails'

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m 'Add `slim-rails` gem as template engine'"
end
