require 'active_model'

class FormObject
  include ActiveModel::Model # for validations
  include Virtus.model # for attributes

  def errors_for(attribute, separator = '</br>')
    return nil if errors[attribute].nil? || errors[attribute].empty?
    errors[attribute].join(separator.html_safe)
  end
end
