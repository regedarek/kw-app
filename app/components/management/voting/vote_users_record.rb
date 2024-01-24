# == Schema Information
#
# Table name: management_vote_users
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#  vote_id    :integer
#
module Management
  module Voting
    class VoteUsersRecord < ActiveRecord::Base
      self.table_name = 'management_vote_users'

      belongs_to :user, class_name: 'Db::User', foreign_key: :user_id
      belongs_to :vote, class_name: 'Management::Voting::VoteRecord', foreign_key: :vote_id
    end
  end
end
