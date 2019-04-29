require_dependency 'custom_fields_helper_patch'

Redmine::Plugin.register :api_expose_custom_fields do
  name 'Api Expose Custom Fields plugin'
  author 'Viktor Kachulin'
  description 'Exposes real values of custom fields in API response'
  version '0.0.1'
  url 'https://github.com/Viktor-KN/redmine_api_expose_custom_fields'
  author_url 'https://github.com/Viktor-KN'

  settings :default => {
    :ecf_api_plugin_enabled => false,
    :ecf_api_for => [],
  }, :partial => 'settings/api_expose_custom_fields_settings'
end
