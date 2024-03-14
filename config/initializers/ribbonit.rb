Ribbonit.configure do |config|
  # rails_version: Version of Ruby on Rails
  # ruby_version: Version of Ruby
  # git_branch: Current git branch (only displayed in development)
  config.infos_to_display = %i[rails_version ruby_version git_branch]

  # additional extra content to display at the bottom of ribbon
  config.extra_content = nil # 'Foo bar'

  config.root_link = false # Wrap ribbon with root_url link ?

  config.hide_for_small = true # Display ribbon in small devices ?
  config.position = 'bottom-right' # top-left, top-right, bottom-left, bottom-right
  config.sticky = true # stick to page corner ?

  # Available colors:
  # orange, blue, green, red, purple, black, white
  config.themes = {
    development: 'green',
    staging: 'orange',
    production: 'red',
    my_custom_environment: 'purple'
  }
end
