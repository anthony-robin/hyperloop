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
say 'It could take a while, please be patient...', :green
say '=============================================================', :green

@port = 3000
@authentication = true
@raw_locales = 'fr,en,es'

# @port = ask('What port do you want the app to run ?', default: 3000)
# @authentication = yes?('Do you want authentication ? (Y/n)')
# @raw_locales = ask('Which locale(s) do you want ? (eg: en,fr)', default: 'en')

@locales = @raw_locales.gsub(/\s+/, '').split(',').compact_blank
@locales.select! { |l| l.size == 2 } # Skip wrongly formatted locales
@locale_no_en = @locales.any? { |l| l != 'en' }

add_template_repository_to_source_path

after_bundle do
  unless options.skip_git?
    git :init
    git add: '-A .'
    git commit: "-m 'Initial commit'"
  end

  apply 'sections/rubocop/template.rb' unless options.skip_rubocop?
  apply 'sections/slim_template/template.rb'
  apply 'sections/simple_form/template.rb'
  apply 'sections/mailers/template.rb' unless options.skip_action_mailer?
  apply 'sections/flash/template.rb'
  apply 'sections/pagy/template.rb'
  apply 'sections/localization/template.rb'

  apply 'sections/storage/template.rb' unless options.skip_active_storage?
  apply 'sections/rich_text/template.rb' unless options.skip_action_text?

  if @authentication
    apply 'sections/authentication/template.rb'
    apply 'sections/action_policy/template.rb'
  end

  apply 'sections/_base/template.rb'

  if options[:css] == 'tailwind'
    apply 'sections/tailwindcss/template.rb'
  elsif options[:css].blank?
    copy_file 'app/assets/stylesheets/application.css', force: true
  end

  apply 'sections/bullet/template.rb'
  apply 'sections/code-annotation/template.rb'

  print_final_instructions
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
