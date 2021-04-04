module Messaging
  class CommentsController < ApplicationController
    def create
      @comment = Messaging::CommentRecord.new(allowed_params)
      @comment.user_id = current_user.id

      create_notification(@comment)

      if @comment.save
        case @comment.commentable_type
        when 'Db::Activities::MountainRoute'
          NotificationCenter::Mailers::CommentsMailer.notify(@comment).deliver_later
        end

        redirect_back(fallback_location: root_path, notice: 'Dodano komentarz!')
      else
        redirect_back(fallback_location: root_path, alert: 'Komentarz nie może być pusty!')
      end
    end

    def update
      @comment = Messaging::CommentRecord.find(params[:id])

      authorize! :manage, @comment

      if @comment.update(allowed_params)
        redirect_back(fallback_location: root_path, notice: 'Dodano komentarz!')
      else
        redirect_back(fallback_location: root_path, alert: 'Wystąpił błąd!')
      end
    end

    def destroy
      comment = Messaging::CommentRecord.find(params[:id])

      authorize! :manage, comment

      comment.destroy
      redirect_back(fallback_location: root_path, notice: 'Zaktualizowano komentarz!')
    end

    private

    def create_notification(comment)
      case comment.commentable_type
      when 'Db::Activities::MountainRoute'
        comment.commentable.colleague_ids.reject{|id| id == comment.user_id }.each do |id|
          notification = NotificationCenter::NotificationRecord.create(
            recipient_id: id,
            actor_id: comment.user_id,
            action: 'commented_route',
            notifiable_id: comment.commentable_id,
            notifiable_type: 'Db::Activities::MountainRoute'
          )
        end
      when 'Settlement::ContractRecord'
        office_king_ids = Db::User.where(":name = ANY(roles)", name: "office_king").map(&:id)
        contract_user_ids = comment.commentable.users.map(&:id)
        recepient_ids = (office_king_ids + contract_user_ids).uniq.reject{|id| id == comment.user_id }

        recepient_ids.each do |id|
          NotificationCenter::NotificationRecord.create(
            recipient_id: id,
            actor_id: comment.user_id,
            action: 'commented_contract',
            notifiable_id: comment.commentable_id,
            notifiable_type: 'Settlement::ContractRecord'
          )
        end
      when 'Management::ProjectRecord'
        comment.commentable.users.map(&:id).reject{|id| id == comment.user_id }.each do |id|
          NotificationCenter::NotificationRecord.create(
            recipient_id: id,
            actor_id: comment.user_id,
            action: 'commented_project',
            notifiable_id: comment.commentable_id,
            notifiable_type: 'Management::ProjectRecord'
          )
        end
      end
    end

    def allowed_params
      params.require(:comment).permit(:body, :commentable_type, :commentable_id)
    end
  end
end
