# Copied from: https://github.com/excid3/jumpstart/
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("hyperloop-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      "https://github.com/anthony-robin/hyperloop.git",
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{hyperloop/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

say "=============================================================", :green
say "Hyperloop 🚄 is building a fresh new Rails app for you ✨", :green
say "It could take while, please be patient...", :green
say "=============================================================", :green

add_template_repository_to_source_path

gem 'action_policy'
gem 'dotenv-rails'
gem 'ffaker'
gem 'meta-tags'
gem 'mission_control-jobs'
gem 'pagy'
gem 'rails-i18n'
gem 'ribbonit'
gem 'simple_form'
gem 'slim-rails'
gem 'sorcery'

gem_group :development do
  gem 'annotaterb'
  gem 'bullet'
  gem 'chusaku', require: false
  gem 'hotwire-livereload'
  gem 'letter_opener_web'
  gem 'ruby-lsp-rails'
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

if options[:database] == 'postgresql'
  template 'docker-compose.yml.tt'
end

directory 'app/services'
copy_file 'app/controllers/application_controller.rb', force: true
copy_file 'app/controllers/sessions_controller.rb'
copy_file 'app/controllers/password_resets_controller.rb'
directory 'app/controllers/me'
directory 'app/controllers/admin'

template 'app/helpers/application_helper.rb', force: true
template 'app/helpers/seo_helper.rb.tt'

copy_file 'app/jobs/callable_job.rb'
copy_file 'app/mailers/user_mailer.rb'

copy_file 'app/views/application/_flash.html.slim'
directory 'app/views/application'
directory 'app/views/user_mailer'
directory 'app/views/sessions'
directory 'app/views/password_resets'
directory 'app/views/me'
directory 'app/views/admin'

copy_file 'config/routes.rb', force: true
directory 'config/routes'
copy_file 'config/initializers/generators.rb'
copy_file 'config/initializers/inflections.rb', force: true
copy_file 'config/initializers/pagy.rb'
copy_file 'config/initializers/ribbonit.rb'

copy_file 'lib/tasks/annotaterb.rake'
copy_file '.annotaterb.yml'

@port = 3000 # ask('What port do you want the app to run ?')

file '.env', <<~ENV
  PORT=#{@port.presence || 3000}
  # SOLID_QUEUE_IN_PUMA="true"
ENV

run 'dotenv -t .env'

after_bundle do
  install_and_configure_simple_form

  template 'app/views/layouts/application.html.slim.tt'
  template 'app/views/layouts/session.html.slim.tt'
  template 'app/views/layouts/admin.html.slim.tt'

  gsub_file 'config/application.rb', /# config.time_zone = .+/, "config.time_zone = 'Europe/Paris'"

  inject_into_file 'config/application.rb', after: /# config.eager_load_paths .+/ do
    <<~RUBY
      \n
      config.i18n.default_locale = :fr
      config.i18n.available_locales = %i[fr en]
    RUBY
  end

  generate('action_text:install')
  rails_command('active_storage:install')

  install_and_configure_sorcery
  install_and_configure_action_policy
  install_and_configure_tailwindcss if options[:css] == "tailwind"

  copy_file 'config/initializers/mission_control.rb'

  generate(:controller, 'homes', 'show', '--skip-routes')
  run 'bundle exec chusaku'

  inject_into_file 'config/environments/development.rb', before: "# Don't care if the mailer can't send." do
    <<-RUBY
      config.action_mailer.default_url_options = {
        host: 'http://localhost', port: ENV.fetch('PORT', 3000)
      }
      config.action_mailer.delivery_method = :letter_opener_web
      config.action_mailer.perform_deliveries = true
    RUBY
  end

  gsub_file 'config/initializers/sorcery.rb', "# user.reset_password_mailer =", "user.reset_password_mailer = UserMailer"

  directory 'config/locales', force: true

  configure_hotwire_livereload
  add_and_configure_bullet
  create_pretty_confirm

  run_migrations_and_seed_database

  finalize
  initial_commit
  print_final_instructions
end

def run_migrations_and_seed_database
  copy_file 'db/seeds.rb', force: true

  rails_command('db:migrate')
  rails_command('db:seed')
end

def finalize
  inject_into_file '.gitignore' do
    <<~GITIGNORE

      !/.env.template
      .DS_Store
    GITIGNORE
  end

  remove_file 'app/views/layouts/application.html.erb'

  run 'rm -r test'
  run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?
end

def install_and_configure_tailwindcss
  directory 'app/assets/stylesheets', force: true
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
  gsub_file 'config/initializers/simple_form.rb', "config.button_class = 'btn'", "config.button_class = 'add-link cursor-pointer'"
  gsub_file 'config/initializers/simple_form.rb', '# config.label_class = nil', "config.label_class = 'inline-block'"
  gsub_file 'config/initializers/simple_form.rb', '# config.input_class = nil', "config.input_class = 'w-full'"
end

def install_and_configure_sorcery
  generate('sorcery:install remember_me reset_password --model User')
  generate('migration add_fields_to_user first_name:string last_name:string role:integer')

  # Update migration null and default value
  migration_file = Dir.glob("db/migrate/*add_fields_to_user.rb").first
  content = File.read(migration_file)
  updated_content = content.gsub(/add_column :users, :role, :integer/, "add_column :users, :role, :integer, null: false, default: 0")
  File.open(migration_file, "w") { |file| file.puts updated_content }

  copy_file 'app/models/application_record.rb', force: true
  copy_file 'app/models/user.rb', force: true
end

def install_and_configure_action_policy
  generate('action_policy:install')
  directory 'app/policies', force: true
end

def configure_hotwire_livereload
  inject_into_file 'config/environments/development.rb', before: /^end/ do
    <<~RUBY
      \n
      config.hotwire_livereload.reload_method = :turbo_stream
    RUBY
  end
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
  git :init
  git add: '.'
  git commit: %Q{ -m 'Initial commit' }
end

def print_final_instructions
  say "============================================================="
  say "Hyperloop 🚄 successfully created your Rails app ! 🎉🎉🎉", :green
  say
  say "Switch to your app by running:"
  say "$ cd #{app_name}", :yellow
  say
  say "Then run:"
  say "$ bin/dev", :yellow
  say
  say "Then open:"
  say "http://localhost:#{@port}", :yellow
  say
  say "Database is already filled with default values of db/seeds.rb. Enjoy!"
  say "============================================================="
end
