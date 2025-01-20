source_paths.unshift(File.dirname(__FILE__))

inject_into_class 'app/controllers/application_controller.rb',
                  'ApplicationController' do
  <<-RUBY
    add_flash_types :warning, :info

  RUBY
end

copy_file 'app/views/application/_flash.html.slim'
copy_file 'app/assets/stylesheets/flash.css' if options[:css].blank?

inject_into_module 'app/helpers/application_helper.rb',
                   'ApplicationHelper' do
  <<-RUBY

  def render_turbo_stream_flash_messages
    turbo_stream.prepend 'flash', partial: 'flash'
  end
  RUBY
end

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m 'Add flash alert/success component'"
end
