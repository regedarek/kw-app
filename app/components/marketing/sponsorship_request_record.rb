module Marketing
  class SponsorshipRequestRecord < ActiveRecord::Base
    include Workflow
    self.table_name = 'marketing_sponsorship_requests'

    mount_uploaders :attachments, Management::AttachmentUploader
    serialize :attachments, JSON

    belongs_to :user, class_name: 'Db::User'
    belongs_to :contractor, class_name: 'Settlement::ContractorRecord'
    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    workflow_column :state
    workflow do
      state :draft
      state :sent
      state :answered
      state :suspended
      state :archived
    end
  end
end
