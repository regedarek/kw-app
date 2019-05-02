module Management
  module Voting
    class VoteRecord < ActiveRecord::Base
      self.table_name = 'management_votes'

      belongs_to :user, class_name: 'Db::User', foreign_key: :user_id, inverse_of: :votes
      belongs_to :case, class_name: 'Management::Voting::CaseRecord', foreign_key: :case_id, inverse_of: :votes
    end
  end
end
