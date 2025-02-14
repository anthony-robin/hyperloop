gem 'dotenv-rails'
gem 'meta-tags'
gem 'mission_control-jobs' unless options.skip_active_job?
gem 'ribbonit'

insert_into_file 'Gemfile', after: /^group :development do\n/ do
  <<-GEMS
  gem 'hotwire-spark'
  GEMS
end

run 'bundle install'

# Config
gsub_file 'config/application.rb', /# config.time_zone = .+/, "config.time_zone = 'Europe/Paris'"

# Initializers
template 'config/initializers/generators.rb'
copy_file 'config/initializers/inflections.rb', force: true
copy_file 'config/initializers/ribbonit.rb'
copy_file 'config/initializers/mission_control.rb' unless options.skip_active_job?

# Homepage
generate :controller, 'welcome', 'index', '--skip-routes --skip-test'

# Models
inject_into_file 'app/models/application_record.rb', before: /^end/ do
  <<-RUBY

  def self.human_enum_name(enum_name, enum_value)
    I18n.t("activerecord.attributes.\#{model_name.i18n_key}.\#{enum_name.to_s.pluralize}.\#{enum_value}")
  end
  RUBY
end

# Routes
template 'config/routes.rb', force: true

# Locales
template 'config/locales/en.yml', force: true if 'en'.in?(@locales)
template 'config/locales/fr.yml' if 'fr'.in?(@locales)

(@locales - %w[en fr]).each do |locale|
  template 'config/locales/en.yml',
           "config/locales/#{locale}.yml"
  gsub_file "config/locales/#{locale}.yml", 'en:', "#{locale}:"
end

# Services
directory 'app/services'

# Jobs
copy_file 'app/jobs/callable_job.rb' unless options.skip_active_job?

# ENV
file '.env', <<~ENV
  PORT=#{@port.presence || 3000}
  # SOLID_QUEUE_IN_PUMA="true"
ENV
run 'dotenv -t .env'

# Application template
template 'app/views/layouts/application.html.slim'
remove_file 'app/views/layouts/application.html.erb'
copy_file 'app/views/application/_turbo_confirm.html.slim'
template 'app/views/application/_header.html.slim'

# SEO module
template 'app/helpers/seo_helper.rb'
template 'config/locales/seo.en.yml' if 'en'.in?(@locales)
template 'config/locales/seo.fr.yml' if 'fr'.in?(@locales)

(@locales - %w[en fr]).each do |locale|
  template 'config/locales/seo.en.yml',
           "config/locales/seo.#{locale}.yml"
  gsub_file "config/locales/seo.#{locale}.yml", 'en:', "#{locale}:"
end

# Pretty JS confirm modale
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

# PG adapter
template 'docker-compose.yml' if options[:database] == 'postgresql' && !options.skip_docker?

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m 'Base scaffold and config for the project'"
end
