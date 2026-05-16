source_paths.unshift(File.dirname(__FILE__))

development_group = /^group :development do\n/

if File.read('Gemfile').match?(development_group)
  inject_into_file 'Gemfile', after: development_group do
    <<~RUBY
      gem "annotaterb", require: false
      gem "chusaku", require: false
    RUBY
  end
else
  append_to_file 'Gemfile' do
    <<~RUBY

      group :development do
        gem "annotaterb", require: false
        gem "chusaku", require: false
      end
    RUBY
  end
end

run 'bundle install'

generate 'annotate_rb:hook'
copy_file 'config/annotaterb.yml'

run 'bundle exec chusaku'
run 'bundle exec annotaterb models'

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m '[Hyperloop] Install and configure `annotaterb` and `chusaku` gems'"
end
