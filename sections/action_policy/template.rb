source_paths.unshift(File.dirname(__FILE__))

gem 'action_policy'

generate 'action_policy:install'

insert_into_file 'app/controllers/application_controller.rb',
                 before: /^end/ do
  <<-RUBY

  rescue_from ActionPolicy::Unauthorized, with: :unauthorized_access

  private

  def unauthorized_access(e)
    policy_name = e.policy.class.to_s.underscore
    message = t "\#{policy_name}.\#{e.rule}", scope: 'action_policy', default: :default

    redirect_back_or_to root_path, alert: message
  end
  RUBY
end

copy_file 'app/policies/application_policy.rb', force: true
directory 'app/policies/admin', force: true if @admin_dashboard

# Locales
copy_file 'config/locales/action_policy.en.yml' if 'en'.in?(@locales)
copy_file 'config/locales/action_policy.fr.yml' if 'fr'.in?(@locales)

(@locales - %w[en fr]).each do |locale|
  copy_file 'config/locales/action_policy.en.yml',
            "config/locales/action_policy.#{locale}.yml"
  gsub_file "config/locales/action_policy.#{locale}.yml", 'en:', "#{locale}:"
end

run 'bin/rubocop -A --fail-level=E' unless options.skip_rubocop?

unless options.skip_git?
  git add: '-A .'
  git commit: "-n -m 'Install and configure `action_policy` authorization gem'"
end
