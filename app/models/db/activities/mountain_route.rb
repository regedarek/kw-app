module Db
  module Activities
    class MountainRoute < ActiveRecord::Base
      before_save :save_boar_length, if: :ski?

      extend FriendlyId
      enum route_type: [:ski, :regular_climbing]
      friendly_id :slug_candidates, use: :slugged
      mount_uploaders :attachments, AttachmentUploader
      mount_uploaders :gps_tracks, Training::Activities::GpsTrackUploader
      serialize :attachments, JSON
      serialize :gps_tracks, JSON
      def self.model_name
        ActiveModel::Name.new(self, nil, "Activities::MountainRoute")
      end
      scope :climbing, -> { where(route_type: [:regular_climbing, :winter_climbing], training: false) }
      scope :skis, -> { where(route_type: :ski, training: false) }
      scope :boars, -> { where(training: [false, true]) }

      belongs_to :user
      has_many :hearts
      has_many :users, through: :hearts, dependent: :destroy
      has_many :route_colleagues, class_name: 'Db::Activities::RouteColleagues'
      has_many :colleagues, through: :route_colleagues, dependent: :destroy
      has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'
      has_many :points, class_name: 'Training::Activities::MountainRoutePointRecord'
      has_many :training_contracts, class_name: 'Training::Activities::UserContractRecord', foreign_key: :route_id

      has_many :photos, as: :uploadable, class_name: 'Storage::UploadRecord'
      accepts_nested_attributes_for :photos

      validates :name, :rating, :climbing_date, presence: true

      def save_boar_length
        if training
          self.boar_length = length / 2
        else
          self.boar_length = length
        end
      end

      def slug_candidates
        [
          [:climbing_date, :name],
          [:route_type, :climbing_date, :name]
        ]
      end

      def category
        return :sww if route_type.nil?

        case route_type.to_sym
        when :ski
          :snw
        else
          :sww
        end
      end

      def persons
        cn = colleagues.map(&:display_name)
        cn = cn.push(partners) if partners.present?
        cn.to_sentence
      end

      def colleagues_names=(ids)
        self.colleague_ids = ids
      end

      attr_reader :colleagues_names
    end
  end
end
