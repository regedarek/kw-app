module Activities
  class MountainRouteRecord < ActiveRecord::Base
    before_save :save_boar_length, if: :ski?
    enum route_type: [:ski, :regular_climbing, :winter_climbing]

    mount_uploaders :attachments, AttachmentUploader
    serialize :attachments, JSON

    self.table_name = 'mountain_routes'

    belongs_to :user, class_name: 'Db::User'

    has_many :hearts, dependent: :destroy, class_name: 'Db::Heart', foreign_key: 'mountain_route_id'
    has_many :users, through: :hearts

    has_many :route_colleagues, class_name: 'Db::Activities::RouteColleagues'
    has_many :colleagues, through: :route_colleagues

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'
    has_many :training_contracts, class_name: 'Training::Activities::UserContractRecord', foreign_key: :route_id

    has_many :photos, as: :uploadable, class_name: 'Storage::UploadRecord'
    accepts_nested_attributes_for :photos

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

    def save_boar_length
      if training
        self.boar_length = length / 2
      else
        self.boar_length = length
      end
    end

    attr_reader :colleagues_names
  end
end
