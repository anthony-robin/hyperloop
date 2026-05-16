gsub_file "config/ci.rb",
          "bin/setup --skip-server",
          "bin/setup --skip-server --skip-seed"

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m '[Hyperloop] Skip seeds on CI setup'"
end
