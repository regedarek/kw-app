module Business
  class MessagesController < ApplicationController
    def create
      conversation = ::Mailboxer::Conversation.find(params[:conversation_id])
      set_participant

      if conversation.participants.any?
        @participant.reply_to_conversation(conversation, params[:body])
      else
        @participant.reply(conversation, [], params[:body])
      end

      sign_up = Business::SignUpRecord.find_by(code: params[:code])

      if sign_up
        redirect_back(fallback_location: course_path(sign_up.course.id, code: params[:code]))
      else
        redirect_back(fallback_location: course_path(conversation.sign_ups.first.course_id, code: params[:code]))
      end
    end

    private

    def set_participant
      if user_signed_in?
        @participant = current_user
      else
        @participant = ::Business::SignUpRecord.find_by!(code: params[:code])
      end
    end
  end
end
