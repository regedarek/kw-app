module Business
  class MessagesController < ApplicationController
    def create
      conversation = ::Mailboxer::Conversation.find(params[:conversation_id])
      course = ::Business::CourseRecord.find(params[:course_id])

      if current_user
        sender = current_user
      else
        sender = ::Business::SignUpRecord.find_by!(code: params[:code])
      end

      receipt = sender.reply_to_conversation(conversation, params[:body])

      redirect_to course_path(course.id, code: params[:code])
    end
  end
end
