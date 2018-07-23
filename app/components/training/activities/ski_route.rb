require 'dry-struct'

module Types
  include Dry::Types.module
end

module Training
  module Activities
    class SkiRoute < Dry::Struct
      constructor_type :strict

      attribute :route_type, Types::Strict::String.default('ski')
      attribute :name, Types::Strict::String
      attribute :climbing_date, Types::Strict::Date
      attribute :hidden, Types::Strict::Bool
      attribute :rating,  Types::Strict::Int
      attribute :colleagues_names, Types::Coercible::Array
      attribute :partners, Types::Strict::String.optional
      attribute :length, Types::Strict::Int
      attribute :description, Types::Strict::String

      class << self
        def from_record(record)
          new(
            name: record.name,
            climbing_date: record.climbing_date,
            hidden: record.hidden,
            rating: record.rating,
            colleagues_names: record.colleagues_names,
            partners: record.partners,
            length: record.length,
            description: record.description
          )
        end
      end
    end
  end
end
