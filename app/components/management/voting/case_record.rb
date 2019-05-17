module Management
  module Voting
    class CaseRecord < ActiveRecord::Base
      include Workflow
      extend FriendlyId

      mount_uploaders :attachments, Management::AttachmentUploader
      serialize :attachments, JSON

      friendly_id :name, use: :slugged
      self.table_name = 'management_cases'

      has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'
      has_many :votes, class_name: 'Management::Voting::VoteRecord', foreign_key: :case_id
      has_many :users, through: :votes, foreign_key: :user_id, dependent: :destroy

      workflow_column :state
      workflow do
        state :draft
        state :voting do
          event :close, :transitions_to => :closed
        end
        state :closed
      end
    end
  end
end
