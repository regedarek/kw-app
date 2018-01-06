require 'dry-struct'

module Events
  class Competition < Dry::Struct
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
