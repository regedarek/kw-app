module Db
  module Activities
    class MountainRoute < ActiveRecord::Base
      extend FriendlyId
      enum route_type: [:ski, :regular_climbing, :winter_climbing]
      friendly_id :slug_candidates, use: :slugged
      mount_uploaders :attachments, AttachmentUploader
      serialize :attachments, JSON
      def self.model_name
        ActiveModel::Name.new(self, nil, "Activities::MountainRoute")
      end
      scope :climbing, -> { where(route_type: [:regular_climbing, :winter_climbing], training: false) }
      scope :ski, -> { where(route_type: :ski, training: false) }
      scope :boars, -> { where(training: [false, true]) }

      belongs_to :user
      has_many :hearts
      has_many :users, through: :hearts, dependent: :destroy
      has_many :route_colleagues, class_name: 'Db::Activities::RouteColleagues'
      has_many :colleagues, through: :route_colleagues, dependent: :destroy
      has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'
      has_many :route_contracts, class_name: '::Training::Activities::RouteContractsRecord', foreign_key: :route_id
      has_many :contracts, through: :route_contracts, dependent: :destroy, class_name: '::Training::Activities::ContractRecord'

      validates :name, :rating, :climbing_date, presence: true

      def slug_candidates
        [
          [:climbing_date, :name],
          [:route_type, :climbing_date, :name]
        ]
      end

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
