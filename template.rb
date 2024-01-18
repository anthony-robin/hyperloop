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

add_template_repository_to_source_path

copy_file 'Gemfile', force: true
template 'docker-compose.yml.tt'

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
copy_file 'app/views/application/_turbo_confirm.html.slim'
template 'app/views/application/_header.html.slim.tt'
directory 'app/views/user_mailer'
directory 'app/views/sessions'
directory 'app/views/password_resets'
directory 'app/views/me'
directory 'app/views/admin'

template 'config/database.yml.tt', force: true
copy_file 'config/routes.rb', force: true
directory 'config/routes'
copy_file 'config/initializers/generators.rb'
copy_file 'config/initializers/inflections.rb', force: true
copy_file 'config/initializers/pagy.rb'
copy_file 'config/initializers/sorcery_monkey.rb'

copy_file 'lib/tasks/annotate.rake'

copy_file 'bin/rubocop'
copy_file '.rubocop.yml'
copy_file '.rubocop-custom.yml'
copy_file '.rubocop-disabled.yml'

port = 3000 # ask('What port do you want the app to run ?')

file '.env', <<~ENV
  PORT=#{port.presence || 3000}
ENV

run 'dotenv -t .env'

after_bundle do
  copy_file 'app/views/layouts/session.html.slim'
  copy_file 'app/views/layouts/application.html.slim'
  copy_file 'app/views/layouts/admin.html.slim'

  gsub_file 'config/application.rb', /# config.time_zone = .+/, "config.time_zone = 'Europe/Paris'"

  inject_into_file 'config/application.rb', after: /# config.eager_load_paths .+/ do
    <<~RUBY
      \n
      config.i18n.default_locale = :fr
      config.i18n.available_locales = %i[fr en]
    RUBY
  end

  install_and_configure_simple_form

  generate('action_text:install') if true # yes?('Do you want ActionText ?')
  rails_command('active_storage:install') if true # yes?('Do you want ActiveStorage ?')

  install_and_configure_sorcery
  install_and_configure_action_policy
  install_and_configure_tailwindcss

  generate('solid_queue:install')

  generate(:controller, 'homes', 'show', '--skip-routes')
  run 'bundle exec chusaku'

  inject_into_file 'config/environments/development.rb', before: "# Don't care if the mailer can't send." do
    <<-RUBY
      config.action_mailer.default_url_options = {
        host: 'http://localhost', port: ENV.fetch('PORT', 3000)
      }
      config.action_mailer.delivery_method = :letter_opener
      config.action_mailer.perform_deliveries = true
    RUBY
  end

  gsub_file 'config/initializers/sorcery.rb', "# user.reset_password_mailer =", "user.reset_password_mailer = UserMailer"

  directory 'config/locales', force: true

  add_and_configure_bullet
  create_pretty_confirm

  run_migrations_and_seed_database

  finalize
  initial_commit
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

  remove_file 'config/initializers/sorcery_monkey.rb'
  remove_file 'app/views/layouts/application.html.erb'

  run 'rm -r test'
  run 'bundle exec rubocop -A --fail-level=E'
end

def install_and_configure_tailwindcss
  rails_command('tailwindcss:install')
  directory 'app/assets/stylesheets', force: true
  copy_file 'config/tailwind.config.js', force: true

  inject_into_file 'config/importmap.rb' do
    <<-RUBY
      pin 'flowbite', to: 'https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.2.1/flowbite.turbo.min.js'
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

  copy_file 'app/models/user.rb', force: true
end

def install_and_configure_action_policy
  generate('action_policy:install')
  directory 'app/policies', force: true
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
