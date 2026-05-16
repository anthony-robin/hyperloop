source_paths.unshift(File.dirname(__FILE__))

inject_into_file 'test/test_helper.rb', before: /\nmodule ActiveSupport/ do
  <<-RUBY

  Rails.root.glob('test/test_helpers/**/*.rb').each { |f| require f }

  RUBY
end

copy_file '.simplecov', '.simplecov'

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m '[Hyperloop] Install and configure testing with minitest'"
end
