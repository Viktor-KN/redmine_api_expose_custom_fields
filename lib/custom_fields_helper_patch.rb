require_dependency 'custom_fields_helper'

module CustomFieldsHelperPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
    end

  end

  module ClassMethods

  end

  module InstanceMethods
    def custom_values_exposed(custom_value, types)
      if custom_value.value.is_a?(Array)
        custom_value.value.each do |value|
          yield custom_value_exposed(custom_value, value, types)
        end
      end
    end

    def custom_value_exposed(custom_value, value, types)
      if types.include?(custom_value.custom_field.field_format)
        custom_value.custom_field.format.formatted_value(self,
                                                         custom_value.custom_field,
                                                         value,
                                                         custom_value.customized,
                                                         false).name
      else
        value
      end
    end

    def render_api_custom_values(custom_values, api)
      return _render_api_custom_values(custom_values, api) unless Setting.plugin_api_expose_custom_fields['ecf_api_plugin_enabled']
      enabled_types = Setting.plugin_api_expose_custom_fields['ecf_api_for']

      api.array :custom_fields do
        custom_values.each do |custom_value|
          attrs = {:id => custom_value.custom_field_id, :name => custom_value.custom_field.name}
          attrs.merge!(:multiple => true) if custom_value.custom_field.multiple?
          api.custom_field attrs do
            if custom_value.value.is_a?(Array)
              api.array :value do
                custom_values_exposed(custom_value, enabled_types) do |value|
                  api.value value unless value.blank?
                end
              end
            else
              api.value custom_value_exposed(custom_value, custom_value.value, enabled_types)
            end
          end
        end
      end unless custom_values.empty?
    end
  end
end

CustomFieldsHelper.send(:alias_method, :_render_api_custom_values, :render_api_custom_values)
CustomFieldsHelper.send(:remove_method, :render_api_custom_values)
CustomFieldsHelper.send(:include, CustomFieldsHelperPatch)
