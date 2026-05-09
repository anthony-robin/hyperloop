source_paths.unshift(File.dirname(__FILE__))

insert_into_file 'Gemfile', after: /^group :development do\n/ do
  <<~GEMS
    gem 'annotaterb', require: false
    gem 'chusaku', require: false
  GEMS
end

run 'bundle install'

generate 'annotate_rb:hook'
copy_file 'config/annotaterb.yml'

run 'bundle exec chusaku'
run 'bundle exec annotaterb models'
run 'bundle exec annotaterb routes'

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m '[Hyperloop] Install and configure `annotaterb` and `chusaku` gems'"
end
