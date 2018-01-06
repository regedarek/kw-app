require 'dry-struct'

module Types
  include Dry::Types.module
end

module Events
  class Competition < Dry::Struct
    constructor_type :strict

    attribute :id, Types::Strict::Int
    attribute :name, Types::Strict::String
    attribute :edition_sym, Types::Strict::Symbol.constructor(&:to_sym)

    class << self
      def from_record(record)
        new(
          id: record.id,
          name: record.name,
          edition_sym: record.edition_sym
        )
      end
    end
  end
end
