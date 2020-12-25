module Messaging
  class CommentRecord < ActiveRecord::Base
    self.table_name = 'comments'

    belongs_to :commentable, polymorphic: true
    belongs_to :user, class_name: 'Db::User'
  end
end
