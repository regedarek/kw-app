# == Schema Information
#
# Table name: route_colleagues
#
#  id                :integer          not null, primary key
#  colleague_id      :integer
#  mountain_route_id :integer
#
# Indexes
#
#  index_route_colleagues_on_colleague_id_and_mountain_route_id  (colleague_id,mountain_route_id) UNIQUE
#
module Db
  module Activities
    class RouteColleagues < ActiveRecord::Base
      belongs_to :colleague, class_name: 'Db::User'
      belongs_to :mountain_route, class_name: 'Db::Activities::MountainRoute'
    end
  end
end
