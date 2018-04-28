require 'dry-struct'

module Types
  include Dry::Types.module
end

module Training
  module Supplementary
    class Course < Dry::Struct
      constructor_type :strict

      attribute :id, Types::Strict::Int
      attribute :name, Types::Strict::String
      attribute :place, Types::Strict::String
      attribute :start_date, Types::Strict::Date
      attribute :end_date, Types::Strict::Date
      attribute :application_date, Types::Strict::Date
      attribute :price_kw, Types::Strict::Int
      attribute :price_non_kw, Types::Strict::Int
      attribute :remarks, Types::Strict::String
      attribute :organizator_id, Types::Strict::Int

      class << self
        def from_record(record)
          new(
            id: record.id,
            name: record.name,
            place: record.place,
            start_date: record.start_date,
            end_date: record.end_date,
            application_date: record.application_date,
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
