source_paths.unshift(File.dirname(__FILE__))

directory 'app/assets/stylesheets', force: true
remove_file 'app/assets/stylesheets/application.css'
copy_file 'config/tailwind.config.js', force: true

inject_into_file 'config/importmap.rb' do
  <<-RUBY
    pin 'flowbite', to: 'https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.5.2/flowbite.turbo.min.js'
  RUBY
end

inject_into_file 'app/javascript/application.js' do
  <<-JAVASCRIPT
  import 'flowbite'
  JAVASCRIPT
end

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m 'Setup TailwindCSS default style and use `flowbite` js library'"
end
