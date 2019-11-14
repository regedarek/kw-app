module Training
  module Activities
    class MountainRoutePointRecord < ActiveRecord::Base
      self.table_name = 'mountain_route_points'

      validates :lat, :lng, :mountain_route_id, presence: true

      belongs_to :mountain_route, class_name: 'Db::Activities::MountainRoute'
    end
  end
end
