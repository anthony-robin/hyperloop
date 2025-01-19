# Copied from: https://github.com/excid3/jumpstart/
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__.match?(%r{\Ahttps?://})
    require 'tmpdir'
    source_paths.unshift(tempdir = Dir.mktmpdir('hyperloop-'))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      '--quiet',
      'https://github.com/anthony-robin/hyperloop.git',
      tempdir
    ].map(&:shellescape).join(' ')

    if (branch = __FILE__[%r{hyperloop/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

say '=============================================================', :green
say 'Hyperloop 🚄 is building a fresh new Rails app for you ✨', :green
say 'It could take while, please be patient...', :green
say '=============================================================', :green

# @port = 3000
@port = ask('What port do you want the app to run ?', default: 3000)
@authentication = yes?('Do you want authentication ? (Y/n)')
@raw_locales = ask('Which locale(s) do you want ? (eg: en,fr)', default: 'en')

@locales = @raw_locales.gsub(/\s+/, '').split(',').compact_blank
@locales.select! { |l| l.size == 2 } # Skip wrongly formatted locales
locale_no_en = @locales.any? { |l| l != 'en' }

add_template_repository_to_source_path

gem 'action_policy'
gem 'active_storage_validations' unless options.skip_active_storage?
gem 'dotenv-rails'
gem 'ffaker'
gem 'meta-tags'
gem 'mission_control-jobs'
gem 'pagy'
gem 'rails-i18n' if @locales.count > 1 || locale_no_en
gem 'ribbonit'
gem 'route_translator' if @locales.count > 1 || locale_no_en
gem 'simple_form'
gem 'slim-rails'

gem_group :development do
  gem 'annotaterb'
  gem 'bullet'
  gem 'chusaku', require: false
  gem 'hotwire-spark'
  gem 'letter_opener_web' unless options.skip_action_mailer?
end

unless options.skip_rubocop?
  gem_group :development, :test do
    gem 'rubocop'
    gem 'rubocop-performance'
    gem 'rubocop-rails'
  end

  copy_file '.rubocop.yml', force: true
  copy_file '.rubocop-custom.yml'
  copy_file '.rubocop-disabled.yml'
  gsub_file 'Gemfile', '# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]', ''
  gsub_file 'Gemfile', 'gem "rubocop-rails-omakase", require: false', ''
  gsub_file 'config/environments/development.rb',
            '# config.generators.apply_rubocop_autocorrect_after_generate!',
            'config.generators.apply_rubocop_autocorrect_after_generate!'
end

template 'docker-compose.yml' if options[:database] == 'postgresql' && !options.skip_docker?

directory 'app/services'
template 'app/controllers/application_controller.rb', force: true

template 'app/helpers/application_helper.rb', force: true

copy_file 'app/jobs/callable_job.rb'
copy_file 'app/models/application_record.rb', force: true

directory 'app/views/application'

template 'config/routes.rb', force: true
directory 'config/routes'
copy_file 'config/initializers/generators.rb'
copy_file 'config/initializers/inflections.rb', force: true
copy_file 'config/initializers/pagy.rb'
copy_file 'config/initializers/ribbonit.rb'

copy_file 'lib/tasks/annotaterb.rake'
copy_file '.annotaterb.yml'

file '.env', <<~ENV
  PORT=#{@port.presence || 3000}
  # SOLID_QUEUE_IN_PUMA="true"
ENV

after_bundle do
  run 'dotenv -t .env'

  install_and_configure_simple_form

  template 'app/views/layouts/application.html.slim'
  template 'app/views/layouts/session.html.slim'
  template 'app/views/layouts/admin.html.slim'

  gsub_file 'config/application.rb', /# config.time_zone = .+/, "config.time_zone = 'Europe/Paris'"

  if @authentication
    install_and_configure_authentication
    install_and_configure_action_policy
  end

  configure_locales

  generate('action_text:install') unless options.skip_action_text?
  rails_command('active_storage:install') unless options.skip_active_storage?

  if options[:css] == 'tailwind'
    install_and_configure_tailwindcss
  elsif options[:css].blank?
    copy_file 'app/assets/stylesheets/application.css', force: true
  end

  template 'config/initializers/mission_control.rb'

  generate(:controller, 'homes', 'show', '--skip-routes')

  unless options.skip_action_mailer?
    inject_into_file 'config/environments/development.rb', before: "# Don't care if the mailer can't send." do
      <<-RUBY
        config.action_mailer.default_url_options = {
          host: 'http://localhost', port: ENV.fetch('PORT', 3000)
        }
        config.action_mailer.delivery_method = :letter_opener_web
        config.action_mailer.perform_deliveries = true
      RUBY
    end
  end

  template 'config/locales/en.yml', force: true if 'en'.in?(@locales)
  template 'config/locales/fr.yml', force: true if 'fr'.in?(@locales)

  if @authentication
    template 'config/locales/activerecord.en.yml' if 'en'.in?(@locales)
    template 'config/locales/activerecord.fr.yml' if 'fr'.in?(@locales)
  end

  setup_seo_module
  add_and_configure_bullet
  create_pretty_confirm

  run_migrations_and_seed_database

  finalize
  initial_commit unless options.skip_git?
  print_final_instructions
end

def run_migrations_and_seed_database
  template 'db/seeds.rb', force: true

  rails_command('db:migrate')
  rails_command('db:seed')
end

def finalize
  remove_file 'app/views/layouts/application.html.erb'

  run 'bundle exec chusaku'
  run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?
end

def install_and_configure_tailwindcss
  directory 'app/assets/stylesheets', force: true
  remove_file 'app/assets/stylesheets/application.css'
  copy_file 'config/tailwind.config.js', force: true

  inject_into_file 'config/importmap.rb' do
    <<-RUBY
      pin 'flowbite', to: 'https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.5.2/flowbite.turbo.min.js'
    RUBY
  end

  inject_into_file 'app/javascript/application.js' do
    <<~JAVASCRIPT
      import 'flowbite'
    JAVASCRIPT
  end
end

def install_and_configure_simple_form
  generate('simple_form:install')
  gsub_file 'config/initializers/simple_form.rb', 'tag: :span, class: :hint', 'tag: :mark, class: :hint'
  gsub_file 'config/initializers/simple_form.rb', 'tag: :span, class: :error', 'tag: :small'

  template 'config/locales/simple_form.en.yml', force: true if 'en'.in?(@locales)
  template 'config/locales/simple_form.fr.yml' if 'fr'.in?(@locales)
end

def install_and_configure_authentication
  generate('authentication')
  generate('migration add_fields_to_user first_name:string last_name:string role:integer')

  # Update migration null and default value for role
  migration_file = Dir.glob('db/migrate/*add_fields_to_user.rb').first
  content = File.read(migration_file)
  updated_content = content.gsub('add_column :users, :role, :integer', 'add_column :users, :role, :integer, null: false, default: 0')
  File.open(migration_file, 'w') { |file| file.puts updated_content }

  copy_file 'app/controllers/registrations_controller.rb'
  directory 'app/controllers/me'
  directory 'app/controllers/admin'
  template 'app/models/user.rb', force: true

  # Views not generated in slim :(
  directory 'app/views/registrations'
  directory 'app/views/sessions', force: true
  directory 'app/views/passwords', force: true unless options.skip_action_mailer?

  directory 'app/views/me'
  directory 'app/views/admin'

  inject_into_file 'app/controllers/sessions_controller.rb',
                   after: 'class SessionsController < ApplicationController' do
    <<-RUBY
      \n
      layout 'session'
    RUBY
  end

  inject_into_file 'app/controllers/sessions_controller.rb',
                   before: 'def new' do
    <<-RUBY
      def show
        redirect_to new_session_path
      end
    RUBY
  end

  inject_into_file 'app/controllers/passwords_controller.rb',
                   after: 'class PasswordsController < ApplicationController' do
    <<-RUBY
      \n
      layout 'session'
    RUBY
  end

  inject_into_file 'app/controllers/registrations_controller.rb',
                   after: 'class RegistrationsController < ApplicationController' do
    <<-RUBY
      \n
      layout 'session'
    RUBY
  end
end

def configure_locales
  main_locale = @locales.first

  puts "Main locale: #{main_locale}"
  puts "Available locales: #{@locales}"

  inject_into_file 'config/application.rb', after: /# config.eager_load_paths .+/ do
    <<~RUBY
      \n
      config.i18n.default_locale = :#{main_locale}
      config.i18n.available_locales = #{@locales.map(&:to_sym)}
    RUBY
  end

  template 'config/locales/routes.en.yml' if 'en'.in?(@locales)
  template 'config/locales/routes.fr.yml' if 'fr'.in?(@locales)

  return unless @authentication

  unless options.skip_action_mailer?
    copy_file 'config/locales/mailers.en.yml' if 'en'.in?(@locales)
    copy_file 'config/locales/mailers.fr.yml' if 'fr'.in?(@locales)

    gsub_file 'app/mailers/passwords_mailer.rb', ' subject: "Reset your password",', ''
  end

  # Session
  gsub_file 'app/controllers/sessions_controller.rb', '"Try again later."', "t('.try_again_later')"
  gsub_file 'app/controllers/sessions_controller.rb', '"Try another email address or password."', "t('.alert')"

  # Registration
  gsub_file 'app/controllers/registrations_controller.rb', '"Successfully signed up!"', "t('.notice')"

  # Password
  gsub_file 'app/controllers/passwords_controller.rb', '"Password reset instructions sent (if user with that email address exists)."', "t('.notice')"
  gsub_file 'app/controllers/passwords_controller.rb', '"Password has been reset."', "t('.notice')"
  gsub_file 'app/controllers/passwords_controller.rb', '"Passwords did not match."', "t('.alert')"
  gsub_file 'app/controllers/passwords_controller.rb', '"Password reset link is invalid or has expired."', "t('.alert_invalid')"

  gsub_file 'app/controllers/concerns/authentication.rb', 'redirect_to new_session_path' do
    <<~RUBY
      I18n.with_locale(params[:locale] || I18n.default_locale) do
        redirect_to new_session_path
      end
    RUBY
  end

  return unless @locales.count > 1

  gsub_file 'config/routes.rb', "resource :session\n  resources :passwords, param: :token", ''
end

def install_and_configure_action_policy
  generate('action_policy:install')
  directory 'app/policies', force: true

  copy_file 'config/locales/action_policy.en.yml' if 'en'.in?(@locales)
  copy_file 'config/locales/action_policy.fr.yml' if 'fr'.in?(@locales)
end

def setup_seo_module
  template 'app/helpers/seo_helper.rb'
  template 'config/locales/seo.en.yml' if 'en'.in?(@locales)
  template 'config/locales/seo.fr.yml' if 'fr'.in?(@locales)
end

def add_and_configure_bullet
  inject_into_file 'config/environments/development.rb', before: /^end/ do
    <<~RUBY
      \n
      config.after_initialize do
        Bullet.enable        = true
        Bullet.bullet_logger = true
        Bullet.add_footer    = true
      end
    RUBY
  end
end

def create_pretty_confirm
  inject_into_file 'app/javascript/application.js' do
    <<~JAVASCRIPT

      // @see https://gorails.com/episodes/custom-hotwire-turbo-confirm-modals
      Turbo.setConfirmMethod((message, element) => {
        let dialog = document.getElementById('turbo-confirm')

        dialog.querySelector('p').textContent = message
        dialog.showModal()

        return new Promise((resolve, reject) => {
          dialog.addEventListener('close', () => {
            resolve(dialog.returnValue == 'confirm')
          }, { once: true })
        })
      })
    JAVASCRIPT
  end
end

def initial_commit
  inject_into_file '.gitignore' do
    <<~GITIGNORE

      !/.env.template
      .DS_Store
    GITIGNORE
  end

  git :init
  git add: '.'
  git commit: %( -m 'Initial commit' )
end

def print_final_instructions
  say '============================================================='
  say 'Hyperloop 🚄 successfully created your Rails app ! 🎉🎉🎉', :green
  say
  say 'Switch to your app by running:'
  say "$ cd #{app_name}", :yellow
  say
  say 'Then run:'
  say '$ bin/dev', :yellow
  say
  say 'Then open:'
  say "http://localhost:#{@port}", :yellow
  say
  say 'Database is already filled with default values of db/seeds.rb. Enjoy!'
  say '============================================================='
end
