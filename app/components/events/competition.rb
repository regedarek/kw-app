require 'dry-struct'

module Types
  include Dry::Types.module
end

module Events
  class Competition < Dry::Struct
    constructor_type :strict

    attribute :id, Types::Strict::Int
    attribute :name, Types::Strict::String

    class << self
      def from_record(record)
        new(
          id: record.id,
          name: record.name
        )
      end
    end
  end
end
