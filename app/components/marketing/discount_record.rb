module Marketing
  class DiscountRecord < ActiveRecord::Base
    extend FriendlyId
    self.table_name = 'marketing_discounts'
    enum amount_type: [:percentages]
    enum category_type: [:shop, :climbing_hall]

    mount_uploaders :attachments, Management::AttachmentUploader
    serialize :attachments, JSON

    mount_uploader :image, Scrappers::ImageUploader

    friendly_id :slug_candidates, use: :slugged

    belongs_to :contractor, class_name: 'Settlement::ContractorRecord'
    belongs_to :user, class_name: 'Db::User'
    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    validates :contractor, presence: true

    delegate :name, to: :contractor, allow_nil: true

    def slug_candidates
      [
        [:name, :id]
      ]
    end
  end
end
