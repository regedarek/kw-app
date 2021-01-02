module Management
  module Voting
    class CaseRecord < ActiveRecord::Base
      include Workflow
      extend FriendlyId

      enum voting_type: [:document, :members]
      enum meeting_type: [:manage, :circle]

      mount_uploaders :attachments, Management::AttachmentUploader
      serialize :attachments, JSON

      friendly_id :name, use: :slugged
      self.table_name = 'management_cases'

      has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord', dependent: :destroy
      has_many :votes, class_name: 'Management::Voting::VoteRecord', foreign_key: :case_id, dependent: :destroy
      has_many :users, through: :votes, foreign_key: :user_id, dependent: :destroy

      workflow_column :state
      workflow do
        state :draft
        state :unactive
        state :voting do
          event :finish, :transitions_to => :finished
        end
        state :finished
      end
    end
  end
end
