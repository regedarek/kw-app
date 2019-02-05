module Db
  module Activities
    class MountainRoute < ActiveRecord::Base
      enum route_type: [:ski, :regular_climbing, :winter_climbing]
      mount_uploaders :attachments, AttachmentUploader
      serialize :attachments, JSON

      scope :climbing, -> { where(route_type: [:regular_climbing, :winter_climbing], training: false) }
      scope :ski, -> { where(route_type: :ski, training: false) }
      scope :boars, -> { ski.merge(where(route_type: :ski, training: [false, true])) }

      belongs_to :user
      has_many :hearts, dependent: :destroy
      has_many :users, through: :hearts
      has_many :route_colleagues, class_name: 'Db::Activities::RouteColleagues'
      has_many :colleagues, through: :route_colleagues

      validates :name, :rating, :climbing_date, presence: true

      def category
        case route_type.to_sym
        when :ski
          :snw
        else
          :sww
        end
      end

      def persons
        colleagues.map(&:display_name).push(partners).to_sentence
      end

      def colleagues_names=(ids)
        self.colleague_ids = ids
      end

      attr_reader :colleagues_names
    end
  end
end
