require 'dry-struct'

module Types
  include Dry::Types.module
end

module Events
  class Competition < Dry::Struct
    constructor_type :strict

    attribute :id, Types::Strict::Int
    attribute :name, Types::Strict::String
    attribute :team_name, Types::Strict::Bool
    attribute :single, Types::Strict::Bool
    attribute :edition_sym, Types::Strict::Symbol.constructor(&:to_sym)
    attribute :baner_url, Types::String
    attribute :rules, Types::String

    class << self
      def from_record(record)
        new(
          id: record.id,
          name: record.name,
          edition_sym: record.edition_sym,
          single: record.single,
          team_name: record.team_name,
          rules: record.rules,
          baner_url: record.baner_url
        )
      end
    end
  end
end
