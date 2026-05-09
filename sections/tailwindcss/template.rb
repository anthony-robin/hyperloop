source_paths.unshift(File.dirname(__FILE__))

directory 'app/assets/stylesheets', force: true
directory 'app/assets/tailwind', force: true

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m '[Hyperloop] Setup `TailwindCSS` and `DaisyUi`'"
end
