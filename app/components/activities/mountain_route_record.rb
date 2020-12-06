module Activities
  class MountainRouteRecord < ActiveRecord::Base
    enum route_type: [:ski, :regular_climbing, :winter_climbing]

    mount_uploaders :attachments, AttachmentUploader
    serialize :attachments, JSON

    self.table_name = 'mountain_routes'

    belongs_to :user
    has_many :hearts, dependent: :destroy, class_name: 'Db::Heart', foreign_key: 'mountain_route_id'
    has_many :users, through: :hearts
    has_many :route_colleagues, class_name: 'Db::Activities::RouteColleagues'
    has_many :colleagues, through: :route_colleagues
    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'
    has_many :user_contracts, class_name: 'Training::Activities::UserContractRecord'

    def colleagues_names=(ids)
      self.colleague_ids = ids
    end

    def category
      case route_type.to_sym
      when :ski
        :snw
      else
        :sww
      end
    end

    attr_reader :colleagues_names
  end
end
