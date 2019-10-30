require 'dry-struct'

module Types
  include Dry::Types.module
end

module Training
  module Activities
    class SkiRoute < Dry::Struct
      attribute :id, Types::Strict::Integer.optional
      attribute :route_type, Types::Strict::String.default('ski')
      attribute :name, Types::Strict::String
      attribute :climbing_date, Types::Strict::Date
      attribute :hidden, Types::Strict::Bool
      attribute :rating,  Types::Strict::Integer
      attribute :colleagues_names, Types::Coercible::Array
      attribute :partners, Types::Strict::String.optional
      attribute :length, Types::Strict::Integer.optional
      attribute :area, Types::Strict::String.optional
      attribute :difficulty, Types::Strict::String.optional
      attribute :description, Types::Strict::String.optional
      attribute :attachments, Types::Coercible::Array

      class << self
        def from_record(record)
          new(
            id: record.id,
            route_type: record.route_type,
            name: record.name,
            climbing_date: record.climbing_date,
            hidden: record.hidden,
            rating: record.rating,
            colleagues_names: record.colleagues_names,
            partners: record.partners,
            length: record.length,
            area: record.area,
            difficulty: record.difficulty,
            description: record.description,
            attachments: record.attachments
          )
        end
      end
    end
  end
end
