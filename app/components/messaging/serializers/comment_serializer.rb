module Messaging
  module Serializers
    class CommentSerializer < ActiveModel::Serializer
      attributes :id, :body, :created_at, :body_to_s

      belongs_to :user, serializer: UserManagement::UserSerializer
      belongs_to :commentable

      def body_to_s
        ActionView::Base.full_sanitizer.sanitize(object.body)
      end
    end
  end
end
