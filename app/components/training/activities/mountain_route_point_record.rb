# == Schema Information
#
# Table name: mountain_route_points
#
#  id                :bigint           not null, primary key
#  description       :text
#  lat               :decimal(10, 6)   not null
#  lng               :decimal(10, 6)   not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  mountain_route_id :integer          not null
#
module Training
  module Activities
    class MountainRoutePointRecord < ActiveRecord::Base
      self.table_name = 'mountain_route_points'

      validates :lat, :lng, :mountain_route_id, presence: true

      belongs_to :mountain_route, class_name: 'Db::Activities::MountainRoute'
    end
  end
end
