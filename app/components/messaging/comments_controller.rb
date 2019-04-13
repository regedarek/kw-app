module Messaging
  class CommentsController < ApplicationController
    def create
      @comment = Messaging::CommentRecord.new(allowed_params)
      @comment.user_id = current_user.id

      if @comment.save
        redirect_back(fallback_location: root_path, notice: 'Dodano komentarz!')
      end
    end

    private

    def allowed_params
      params.require(:comment).permit(:body, :commentable_type, :commentable_id)
    end
  end
end
