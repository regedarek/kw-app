module Messaging
  module Api
    class CommentsController < ApplicationController
      include Pagy::Backend
      after_action { pagy_headers_merge(@pagy) if @pagy }

      def index
        comments = Messaging::CommentRecord.order(created_at: :desc)
        comments = comments.where(user_id: params[:user_id]) if params[:user_id]

        @pagy, records = pagy(comments)

        render json: records, each_serializer: Messaging::Serializers::CommentSerializer
      end
    end
  end
end
