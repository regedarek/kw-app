module Db
  module Activities
    class RouteColleagues < ActiveRecord::Base
      belongs_to :colleague, class_name: 'Db::User'
      belongs_to :mountain_route, class_name: 'Db::Activities::MountainRoute'
    end
  end
end
