require 'active_model'
require 'input_cleaner'
require 'attributed_object'

class FormObject
  include ActiveModel::Model # for validations
  include AttributedObject::Coerce # for attributes
  attributed_object(default_to: AttributedObject::TypeDefaults.new)

  def errors_for(attribute, separator = '</br>')
    return nil if errors[attribute].nil? || errors[attribute].empty?
    errors[attribute].join(separator).html_safe
  end

  def self.build_cleaned(params = HashWithIndifferentAccess.new)
    return new if params.nil?

    new(InputCleaner.clean_params(params))
  end
end
