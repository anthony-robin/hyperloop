source_paths.unshift(File.dirname(__FILE__))

gem 'simple_form'

generate 'simple_form:install'

gsub_file 'config/initializers/simple_form.rb', 'tag: :span, class: :hint', 'tag: :mark, class: :hint'
gsub_file 'config/initializers/simple_form.rb', 'tag: :span, class: :error', 'tag: :small'

# Locales
if 'en'.in?(@locales)
  template 'config/locales/simple_form.en.yml', force: true
else
  remove_file 'config/locales/simple_form.en.yml'
end

template 'config/locales/simple_form.fr.yml' if 'fr'.in?(@locales)

(@locales - %w[en fr]).each do |locale|
  template 'config/locales/simple_form.en.yml',
           "config/locales/simple_form.#{locale}.yml"
  gsub_file "config/locales/simple_form.#{locale}.yml", 'en:', "#{locale}:"
end

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m 'Install and configure `simple_form` gem'"
end
