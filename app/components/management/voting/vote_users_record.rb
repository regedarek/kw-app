module Management
  module Voting
    class VoteUsersRecord < ActiveRecord::Base
      self.table_name = 'management_vote_users'

      belongs_to :user, class_name: 'Db::User', foreign_key: :user_id
      belongs_to :vote, class_name: 'Management::Voting::VoteRecord', foreign_key: :vote_id
    end
  end
end
