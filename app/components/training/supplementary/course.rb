require 'dry-struct'

module Types
  include Dry::Types.module
end

module Training
  module Supplementary
    class Course < Dry::Struct
      constructor_type :strict

      attribute :id, Types::Strict::Int.optional
      attribute :category, Types::Strict::String
      attribute :name, Types::Strict::String.optional
      attribute :place, Types::Strict::String.optional
      attribute :start_date, Types::Strict::Date.optional
      attribute :end_date, Types::Strict::Date.optional
      attribute :application_date, Types::Strict::Date.optional
      attribute :price_kw, Types::Strict::Int.optional
      attribute :price_non_kw, Types::Strict::Int.optional
      attribute :remarks, Types::Strict::String.optional
      attribute :organizator_id, Types::Any.optional

      def organizer
        if ::Db::User.exists?(id: organizator_id)
          ::Db::User.find(organizator_id)&.display_name
        else
          ''
        end
      end

      class << self
        def from_record(record)
          new(
            id: record.id,
            category: record.category,
            name: record.name,
            place: record.place,
            start_date: record.start_date&.to_date,
            end_date: record.end_date&.to_date,
            application_date: record.application_date&.to_date,
            price_kw: record.price_kw,
            price_non_kw: record.price_non_kw,
            remarks: record.remarks,
            organizator_id: record.organizator_id
          )
        end
      end
    end
  end
end
