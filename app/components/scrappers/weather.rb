require 'dry-types'
require 'dry-struct'

Dry::Types.load_extensions(:maybe)
module Types
  include Dry.Types(default: :nominal)
end

module Scrappers
  class Weather < Dry::Struct
    transform_keys(&:to_sym)

    attribute :place, Types::Strict::String
    attribute :temp, Types::Coercible::Float.optional
    attribute :all_snow, Types::Coercible::Float.optional
    attribute :daily_snow, Types::Coercible::Float.optional
    attribute :snow_type, Types::Coercible::Float.optional
    attribute :wind_value, Types::Coercible::Integer.optional
    attribute :wind_direction, Types::Coercible::Integer.optional
    attribute :cloud_url, Types::Coercible::String.optional
    attribute :snow_surface, Types::Coercible::String.optional
    attribute :snow_type_text, Types::Coercible::String.optional

    def to_attributes
      {
        place: place,
        temp: (temp == 'b.d.' ? nil : temp),
        all_snow: (all_snow == 'b.d.' ? nil : all_snow),
        daily_snow: (daily_snow == 'b.d.' ? nil : daily_snow),
        snow_type: (snow_type == 'b.d.' ? nil : snow_type),
        wind_value: wind_value,
        wind_direction: wind_direction,
        cloud_url: cloud_url,
        snow_type_text: snow_type,
        snow_surface: all_snow
      }
    end
  end
end
