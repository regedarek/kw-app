module Management
  module Voting
    class CaseRecord < ActiveRecord::Base
      include Workflow
      extend FriendlyId

      friendly_id :name, use: :slugged
      self.table_name = 'management_cases'

      has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

      workflow_column :state
      workflow do
        state :draft
        state :voting
        state :suspended
        state :archived
      end
    end
  end
end
