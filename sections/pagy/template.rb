source_paths.unshift(File.dirname(__FILE__))

gem 'pagy', '>= 43'

copy_file 'config/initializers/pagy.rb'

inject_into_class 'app/controllers/application_controller.rb',
                  'ApplicationController' do
  <<-RUBY
  include Pagy::Method

  RUBY
end

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m '[Hyperloop] Install and configure `pagy` as pagination gem'"
end
