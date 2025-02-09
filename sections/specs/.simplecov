return unless ENV['COVERAGE']

SimpleCov.start :rails do
  formatter SimpleCov::Formatter::HTMLFormatter

  add_filter 'app/channels/'

  add_group 'Policies', 'app/policies'
  add_group 'Services', 'app/services'
  add_group 'Decorators', 'app/decorators'
end
