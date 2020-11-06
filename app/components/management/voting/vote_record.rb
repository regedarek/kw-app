module Management
  module Voting
    class VoteRecord < ActiveRecord::Base
      include Workflow

      self.table_name = 'management_votes'

      belongs_to :user, class_name: 'Db::User', foreign_key: :user_id, inverse_of: :votes
      belongs_to :case, class_name: 'Management::Voting::CaseRecord', foreign_key: :case_id, inverse_of: :votes

      has_many :vote_users, class_name: 'Management::Voting::VoteUsersRecord', foreign_key: :vote_id
      has_many :users, through: :vote_users, foreign_key: :user_id, dependent: :destroy

      validates :user_id, uniqueness: { scope: :case_id }

      workflow_column :decision
      workflow do
        state :approved
        state :unapproved
        state :abstained
      end

      def decision_to_s
        case decision
        when 'approved'
          'Za'
        when 'unapproved'
          'Przeciw'
        when 'abstained'
          'Wstrzymano się'
        else
          'Nie wiadomo'
        end
      end
    end
  end
end
