module Shop
  class ItemRecord < ActiveRecord::Base
    extend FriendlyId
    include Workflow
    self.table_name = 'shop_items'
    friendly_id :slug_candidates, use: :slugged

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'
    has_many :photos, as: :uploadable, class_name: 'Storage::UploadRecord'

    def slug_candidates
      [
        [:name]
      ]
    end

    workflow_column :state
    workflow do
      state :draft do
        event :publish, transitions_to: :published
      end
      state :published
    end
  end
end
