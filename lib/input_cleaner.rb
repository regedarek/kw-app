require 'parsing_strings'

module InputCleaner
  module_function

  def clean_params(params)
    case params
    when String then params = ParsingStrings.strip_wrong_encoding_chars(params)
    when Array
      params.each_with_index do |value, index|
        params[index] = clean_params(value)
      end
    when Hash
      params.each_pair do |key, value|
        params[key] = clean_params(value)
      end
    end
    params
  end
end
