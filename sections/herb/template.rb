source_paths.unshift(File.dirname(__FILE__))

insert_into_file 'Gemfile', after: /^group :development do\n/ do
  <<-GEMS
  gem 'herb'
  GEMS
end

run 'bundle install'

template '.herb.yml'

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m '[Hyperloop] Install and configure `herb` code linter and formatter'"
end
