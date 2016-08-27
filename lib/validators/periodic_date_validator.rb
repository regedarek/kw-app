class PeriodicDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, parameters)
    if invalid(attribute, parameters)
      record.errors[attribute] << 'attribute is invalid.'
    end
  end
end
