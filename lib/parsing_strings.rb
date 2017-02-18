module ParsingStrings
  module_function

  def strip_wrong_encoding_chars(field)
    return field if field.blank?
    field.each_char.select { |c| c.bytes.count < 4 }.join('')
  end
end
