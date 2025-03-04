source_paths.unshift(File.dirname(__FILE__))

gem 'ffaker'

run 'bundle install'

# Rails 8 authentication
generate 'authentication'
generate 'migration add_fields_to_user first_name:string last_name:string role:integer'

# Update migration null and default value for role
migration_file = Dir.glob('db/migrate/*add_fields_to_user.rb').first
content = File.read(migration_file)
updated_content = content.gsub('add_column :users, :role, :integer', 'add_column :users, :role, :integer, null: false, default: 0')
File.open(migration_file, 'w') { |file| file.puts updated_content }

copy_file 'app/controllers/registrations_controller.rb'
directory 'app/controllers/me'
template 'app/models/user.rb', force: true
template 'app/views/layouts/session.html.slim'
directory 'app/views/me'
copy_file 'config/routes/me.rb'
gsub_file 'config/routes.rb', '# /me template', 'draw :me'

# Views not generated in slim :(
directory 'app/views/registrations'
directory 'app/views/sessions', force: true
directory 'app/views/passwords', force: true unless options.skip_action_mailer?

gsub_file 'config/routes.rb', "resource :session\n  resources :passwords, param: :token", '' # if @locales.count > 1

# Locales
template 'config/locales/activerecord.en.yml' if 'en'.in?(@locales)
template 'config/locales/activerecord.fr.yml' if 'fr'.in?(@locales)

(@locales - %w[en fr]).each do |locale|
  template 'config/locales/activerecord.en.yml',
           "config/locales/activerecord.#{locale}.yml"
  gsub_file "config/locales/activerecord.#{locale}.yml", 'en:', "#{locale}:"
end

gsub_file 'app/controllers/sessions_controller.rb', '"Try again later."', "t('.try_again_later')"
gsub_file 'app/controllers/sessions_controller.rb', '"Try another email address or password."', "t('.alert')"
gsub_file 'app/controllers/registrations_controller.rb', '"Successfully signed up!"', "t('.notice')"
gsub_file 'app/controllers/passwords_controller.rb', '"Password reset instructions sent (if user with that email address exists)."', "t('.notice')"
gsub_file 'app/controllers/passwords_controller.rb', '"Password has been reset."', "t('.notice')"
gsub_file 'app/controllers/passwords_controller.rb', '"Passwords did not match."', "t('.alert')"
gsub_file 'app/controllers/passwords_controller.rb', '"Password reset link is invalid or has expired."', "t('.alert_invalid')"
gsub_file 'app/controllers/concerns/authentication.rb', 'redirect_to new_session_path' do
  <<-RUBY
  I18n.with_locale(params[:locale] || I18n.default_locale) do
    redirect_to new_session_path
  end
  RUBY
end

# Layout
inject_into_class 'app/controllers/sessions_controller.rb',
                  'SessionsController' do
  <<-RUBY
  layout 'session'

  RUBY
end

inject_into_file 'app/controllers/sessions_controller.rb',
                 before: 'def new' do
  <<-RUBY
  def show
    # `show` is present only to avoid a 404 when accessing /session
  end

  RUBY
end

inject_into_file 'app/controllers/sessions_controller.rb',
                 after: "def new\n" do
  <<-RUBY
  redirect_to root_path if authenticated?
  RUBY
end

inject_into_class 'app/controllers/passwords_controller.rb',
                  'PasswordsController' do
  <<-RUBY
  layout 'session'

  RUBY
end

inject_into_class 'app/controllers/registrations_controller.rb',
                  'RegistrationsController' do
  <<-RUBY
  layout 'session'

  RUBY
end

gsub_file 'app/controllers/concerns/authentication.rb', 'helper_method :authenticated?', 'helper_method :authenticated?, :current_user'

inject_into_file 'app/controllers/concerns/authentication.rb', after: /private\n/ do
  <<-RUBY

  def current_user
    @current_user ||= Current.user
  end

  RUBY
end

template 'db/seeds.rb', force: true
rails_command 'db:migrate db:seed'

copy_file 'spec/requests/me/profiles_spec.rb' unless options.skip_test?

# Mailers

unless options.skip_action_mailer?
  copy_file 'config/locales/mailers.en.yml' if 'en'.in?(@locales)
  copy_file 'config/locales/mailers.fr.yml' if 'fr'.in?(@locales)

  (@locales - %w[en fr]).each do |locale|
    copy_file 'config/locales/mailers.en.yml',
              "config/locales/mailers.#{locale}.yml"
    gsub_file "config/locales/mailers.#{locale}.yml", 'en:', "#{locale}:"
  end

  gsub_file 'app/mailers/passwords_mailer.rb', ' subject: "Reset your password",', ''

  unless options.skip_test?
    copy_file 'spec/mailers/passwords_mailer_spec.rb'

    # Move mailer preview to spec folder
    empty_directory 'spec/mailers/previews'
    FileUtils.move 'test/mailers/previews/passwords_mailer_preview.rb', 'spec/mailers/previews/passwords_mailer_preview.rb',
                   force: true

    remove_dir 'test'
  end
end

unless options.skip_test?
  copy_file 'spec/models/user_spec.rb'
  copy_file 'spec/requests/sessions_spec.rb'
  copy_file 'spec/requests/registrations_spec.rb'
  copy_file 'spec/requests/passwords_spec.rb'
end

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m 'Install and configure Rails 8 authentication'"
end

# Admin dashboard

if @admin_dashboard
  directory 'app/controllers/admin'
  directory 'app/views/admin'
  template 'app/views/layouts/admin.html.slim'

  template 'config/routes/admin.rb.tt'
  gsub_file 'config/routes.rb', '# /admin template', 'draw :admin'

  unless options.skip_active_job?
    inject_into_file 'config/initializers/mission_control.rb', before: /^end/ do
      <<-RUBY
      MissionControl::Jobs.base_controller_class = 'Admin::ApplicationController'
      RUBY
    end
  end

  gem 'pretender'

  inject_into_file 'app/controllers/application_controller.rb', after: /allow_browser versions: :modern\n/ do
    <<-RUBY

      impersonates :user

    RUBY
  end

  unless options.skip_test?
    copy_file 'spec/requests/admin/dashboards_spec.rb'
    copy_file 'spec/requests/admin/users_spec.rb'
  end

  run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

  unless options.skip_git?
    git add: '-A .'
    git commit: "-n -m 'Scaffold admin dashboard'"
  end
end
