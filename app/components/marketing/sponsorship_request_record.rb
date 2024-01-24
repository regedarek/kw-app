# == Schema Information
#
# Table name: marketing_sponsorship_requests
#
#  id            :bigint           not null, primary key
#  attachments   :string
#  description   :string
#  doc_url       :string
#  sent_at       :datetime
#  state         :string           default("draft"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  contractor_id :integer          not null
#  user_id       :integer          not null
#
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
