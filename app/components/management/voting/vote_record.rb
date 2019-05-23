module Management
  module Voting
    class VoteRecord < ActiveRecord::Base
      include Workflow

      self.table_name = 'management_votes'

      belongs_to :user, class_name: 'Db::User', foreign_key: :user_id, inverse_of: :votes
      belongs_to :case, class_name: 'Management::Voting::CaseRecord', foreign_key: :case_id, inverse_of: :votes

      workflow_column :decision
      workflow do
        state :approved
        state :unapproved
        state :abstained
      end
    end
  end
end
