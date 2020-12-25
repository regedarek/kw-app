module Messaging
  class CommentRecord < ActiveRecord::Base
    self.table_name = 'comments'

    default_scope { order(created_at: :desc) }

    belongs_to :commentable, polymorphic: true
    belongs_to :user, class_name: 'Db::User'
  end
end
