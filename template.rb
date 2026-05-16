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

def extract_option(name, default)
  arg = ARGV.find { |a| a.start_with?("--#{name}=") }
  return default unless arg

  arg.split("=").last
end

begin
  require 'gum'
rescue
  run 'gem install gum'
  require 'gum'
end

# Can be used in the rails new command
# @example:
#   rails new myapp -m template.rb -- --port=4000
@port = extract_option("port", nil)

Gum::Log.info("Hyperloop 🚄 is building a fresh new Rails app for you ✨")
Gum::Log.info("It could take a while, please be patient...")

if @port.nil?
  @port = Gum.input(value: 3000, header: "What port do you want the app to run ?", char_limit: 4)
end

@locales = Gum.choose(['en', 'fr'], header: "Which locale(s) do you want ?", selected: ['en'], no_limit: true)
@locales = ['en'] if @locales.blank?

@authentication = Gum.confirm("Do you need authentication ?", default: true)
@admin_dashboard = Gum.confirm("Do you need an admin dashboard ?", default: true) if @authentication

data = [
  ["App name", camelized],
  ["Port", @port],
  ["Locales", @locales.join('/')],
  ["Authentication", @authentication],
  ["Dashboard admin", @admin_dashboard || 'false']
]
Gum.table(data, columns: %w[Option Value], print: true)

@locale_no_en = @locales.any? { |l| l != 'en' }

@pico_cdn_url = 'https://cdn.jsdelivr.net/npm/@yohns/picocss@2.2.10/css/pico.min.css'

add_template_repository_to_source_path

after_bundle do
  unless options.skip_git?
    git :init
    git add: '-A .'
    git commit: "-m '[Hyperloop] Initial commit'"
  end

  apply 'sections/herb/template.rb'
  apply 'sections/rubocop/template.rb' unless options.skip_rubocop?
  apply 'sections/simple_form/template.rb'
  apply 'sections/pagy/template.rb'
  apply 'sections/flash/template.rb'
  apply 'sections/mailers/template.rb' unless options.skip_action_mailer?
  apply 'sections/localization/template.rb'

  apply 'sections/storage/template.rb' unless options.skip_active_storage?
  apply 'sections/rich_text/template.rb' unless options.skip_action_text?

  apply 'sections/_base/template.rb'
  apply 'sections/test/template.rb' unless options.skip_test?

  if @authentication
    apply 'sections/authentication/template.rb'
    apply 'sections/action_policy/template.rb'
  end

  if options[:css] == 'tailwind'
    apply 'sections/tailwindcss/template.rb'
  elsif options[:css].blank?
    copy_file 'app/assets/stylesheets/application.css', force: true
  end

  apply 'sections/bullet/template.rb'
  apply 'sections/code-annotation/template.rb'
  apply 'sections/ci/template.rb'

  print_final_instructions
end

def print_final_instructions
  say
  Gum::Log.info("Hyperloop 🚄 successfully created your Rails application ! 🎉🎉🎉")

  Gum::Log.info("Switch to your app folder:")
  say "$ cd #{app_name}", :yellow
  say

  Gum::Log.info("Run the dev server:")
  say '$ bin/dev', :yellow
  say

  Gum::Log.info("Open homepage:")
  say "=> http://localhost:#{@port}", :yellow

  if @authentication
    say
    Gum::Log.info('Database is already filled with default values from db/seeds.rb.')

    say '=> Connect with credentials [super_]admin@demo.test / password', :yellow
  end

  say
  Gum::Log.info('Happy coding !')
end
