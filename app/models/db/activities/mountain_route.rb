module Db
  module Activities
    class MountainRoute < ActiveRecord::Base
      enum route_type: [:ski, :regular_climbing, :winter_climbing]
      mount_uploaders :photos, PhotoUploader
      serialize :photos, JSON # If you use SQLite, add this line.

      belongs_to :user
      has_many :colleagues, through: :route_colleagues
      has_many :route_colleagues, class_name: 'Db::Activities::RouteColleagues'

      validates :name, :rating, :climbing_date, presence: true

      def colleagues_names=(ids)
        self.colleague_ids = ids
      end

      attr_reader :colleagues_names
    end
  end
end
