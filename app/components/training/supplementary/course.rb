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
      attribute :start_date, Types::Strict::DateTime.optional
      attribute :end_date, Types::Strict::Date.optional
      attribute :application_date, Types::Strict::DateTime.optional
      attribute :price_kw, Types::Strict::Int.optional
      attribute :price_non_kw, Types::Strict::Int.optional
      attribute :remarks, Types::Strict::String.optional
      attribute :organizator_id, Types::Any.optional
      attribute :price, Types::Strict::Bool
      attribute :cash, Types::Strict::Bool
      attribute :open, Types::Strict::Bool
      attribute :last_fee_paid, Types::Strict::Bool
      attribute :active, Types::Strict::Bool
      attribute :one_day, Types::Strict::Bool
      attribute :limit, Types::Strict::Int

      def sign_ups
        Training::Supplementary::SignUpRecord.where(course_id: id)
      end

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
            start_date: record.start_date&.to_datetime,
            end_date: record.end_date&.to_date,
            application_date: record.application_date&.to_datetime,
            price_kw: record.price_kw,
            price_non_kw: record.price_non_kw,
            remarks: record.remarks,
            organizator_id: record.organizator_id,
            price: record.price,
            cash: record.cash,
            one_day: record.one_day,
            active: record.active,
            limit: record.limit,
            open: record.open,
            last_fee_paid: record.last_fee_paid
          )
        end
      end
    end
  end
end
