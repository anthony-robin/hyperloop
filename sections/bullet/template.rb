source_paths.unshift(File.dirname(__FILE__))

insert_into_file 'Gemfile', after: /^group :development, :test do\n/ do
  <<-GEMS
  gem 'bullet', '>= 8.0' # Rails 8+ requires Bullet 8+
  GEMS
end

run 'bundle install'

inject_into_file 'config/environments/development.rb', before: /^end/ do
  <<-RUBY

  config.after_initialize do
    Bullet.enable        = true
    Bullet.bullet_logger = true
    Bullet.add_footer    = true
  end
  RUBY
end

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m 'Install and configure `bullet` N+1 tracker gem'"
end
