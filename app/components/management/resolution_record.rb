module Management
  class ResolutionRecord < ActiveRecord::Base
    include Workflow
    extend FriendlyId
    friendly_id :name, use: :slugged
    self.table_name = 'management_resolutions'

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    has_many :attachments, as: :uploadable, class_name: 'Storage::UploadRecord'
    accepts_nested_attributes_for :attachments

    workflow_column :state
    workflow do
      state :draft
      state :published
    end
  end
end
