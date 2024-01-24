# == Schema Information
#
# Table name: management_votes
#
#  id            :bigint           not null, primary key
#  commission    :boolean          default(FALSE), not null
#  decision      :string           default("approved"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  authorized_id :integer
#  case_id       :integer          not null
#  user_id       :integer          not null
#
# Indexes
#
#  index_management_votes_on_user_id_and_case_id  (user_id,case_id) UNIQUE
#
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
