# == Schema Information
#
# Table name: comments
#
#  id               :bigint           not null, primary key
#  body             :text
#  commentable_type :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  commentable_id   :integer          not null
#  user_id          :integer          not null
#
module Messaging
  class CommentRecord < ActiveRecord::Base
    self.table_name = 'comments'

    belongs_to :commentable, polymorphic: true
    belongs_to :user, class_name: 'Db::User'

    validates :body, presence: true
  end
end
