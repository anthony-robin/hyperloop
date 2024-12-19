Rails.application.config.generators do |g|
  g.orm :active_record
  g.assets false
  g.helper false
  g.jbuilder false
  g.view_specs false
  g.routing_specs false
  g.test_framework nil
  g.template_engine :slim
end
