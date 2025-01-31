source_paths.unshift(File.dirname(__FILE__))

if @locales.count > 1 || @locale_no_en
  gem 'rails-i18n'
  gem 'route_translator'
end

if @locales.count > 1
  copy_file 'app/views/application/_locale_switcher.html.slim'
  copy_file 'app/controllers/concerns/localizable.rb'

  inject_into_class 'app/controllers/application_controller.rb',
                    'ApplicationController' do
    <<-RUBY
    include Localizable
    RUBY
  end
end

inject_into_file 'config/application.rb', after: /# config.eager_load_paths .+/ do
  <<-RUBY

  config.i18n.default_locale = :#{@locales.first}
  config.i18n.available_locales = #{@locales.map(&:to_sym)}
  RUBY
end

# Locales
template 'config/locales/routes.en.yml' if 'en'.in?(@locales)
template 'config/locales/routes.fr.yml' if 'fr'.in?(@locales)

(@locales - %w[en fr]).each do |locale|
  template 'config/locales/routes.en.yml',
           "config/locales/routes.#{locale}.yml"
  gsub_file "config/locales/routes.#{locale}.yml", 'en:', "#{locale}:"
end

remove_file 'config/locales/en.yml' unless 'en'.in?(@locales)

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m 'Make project multilocales friendly for #{@locales.map(&:to_sym)}'"
end
