require 'dry-struct'

module Types
  include Dry::Types.module
end

module Blog
  class Author < Dry::Struct
    attribute :id, Types::Strict::Integer
    attribute :display_name, Types::Strict::String
    attribute :website, Types::Strict::String.optional
    attribute :url, Types::Strict::String.optional
    attribute :facebook, Types::Strict::String.optional
    attribute :instagram, Types::Strict::String.optional
    attribute :last_ski_route, Types::Strict::String.optional
    attribute :sum_of_ski_meters, Types::Strict::Integer.optional

    class << self
      def from_record(record)
        new(
          id: record.id,
          display_name: record.display_name,
          url: record.author_url,
          website: '',
          facebook: '',
          instagram: '',
          last_ski_route: last_ski_route(record),
          sum_of_ski_meters: sum_of_ski_meters(record)
        )
      end

      private

      def last_ski_route(user)
        ski_routes = Db::Activities::RouteColleagues.includes(:mountain_route).where(mountain_routes: {route_type: 0}, colleague_id: user.id).map(&:mountain_route).compact
        ski_routes.last.name
      end

      def sum_of_ski_meters(user)
        ski_routes = Db::Activities::RouteColleagues.includes(:mountain_route).where(mountain_routes: {route_type: 0}, colleague_id: user.id).map(&:mountain_route).compact
        ski_routes.inject(0) { |sum, r| sum + r.length.to_i }
      end
    end
  end
end
