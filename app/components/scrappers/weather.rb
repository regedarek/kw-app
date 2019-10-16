require 'dry-types'
require 'dry-struct'

Dry::Types.load_extensions(:maybe)
module Types
  include Dry::Types.module
end

module Scrappers
  class Weather < Dry::Struct
    transform_keys(&:to_sym)

    attribute :place, Types::Strict::String
    attribute :temp, Types::Coercible::Float.optional
    attribute :all_snow, Types::Coercible::Float.optional
    attribute :daily_snow, Types::Coercible::Float.optional
    attribute :snow_type, Types::Coercible::Float.optional

    def to_attributes
      {
        place: place,
        temp: (temp == 'b.d.' ? nil : temp),
        all_snow: (all_snow == 'b.d.' ? nil : all_snow),
        daily_snow: (daily_snow == 'b.d.' ? nil : daily_snow),
        snow_type: (snow_type == 'b.d.' ? nil : snow_type),
      }
    end
  end
end
