require 'dry-struct'

module Types
  include Dry.Types(default: :nominal)
end

module Blog
  class Author < Dry::Struct
    attribute :id, Types::Strict::Integer
    attribute :display_name, Types::Strict::String
    attribute :website, Types::Strict::String.optional
    attribute :blog_id, Types::Strict::Integer.optional
    attribute :facebook, Types::Strict::String.optional
    attribute :bio, Types::Strict::String.optional
    attribute :instagram, Types::Strict::String.optional
    attribute :avatar, Types::Strict::String.optional
    attribute :last_ski_route, Types::Strict::String.optional
    attribute :sum_of_ski_meters, Types::Strict::Integer.optional

    class << self
      def from_record(record)
        new(
          id: record.id,
          display_name: record.display_name,
          blog_id: record.author_number,
          website: record.website_url,
          facebook: record.facebook_url,
          instagram: record.instagram_url,
          bio: ActionView::Base.full_sanitizer.sanitize(record.description),
          avatar: avatar(record),
          last_ski_route: last_ski_route(record),
          sum_of_ski_meters: sum_of_ski_meters(record)
        )
      end

      private

      def avatar(record)
        if record.avatar.present?
          record.avatar.url
        else
          ActionController::Base.helpers.image_url('default-avatar.png')
        end
      end

      def last_ski_route(user)
        ski_routes = Db::Activities::RouteColleagues.includes(:mountain_route).where(mountain_routes: {route_type: 0}, colleague_id: user.id).order('mountain_routes.climbing_date').map(&:mountain_route).compact
        if ski_routes.any?
          ski_routes.last.name
        else
          nil
        end
      end

      def sum_of_ski_meters(user)
        ski_routes = Db::Activities::RouteColleagues.includes(:mountain_route).where(mountain_routes: {route_type: 0}, colleague_id: user.id).map(&:mountain_route).compact
        ski_routes.inject(0) { |sum, r| sum + r.length.to_i }
      end
    end
  end
end
