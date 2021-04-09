module Messaging
  class MessagesController < ApplicationController
    before_action :set_conversation

    def create
      authorize! :create, Mailboxer::Conversation

      if params[:body].present?
        receipt = current_user.reply_to_conversation(@conversation, params[:body])
        redirect_to conversation_path(@conversation)
      else
        flash[:alert] = 'Odpowiedź nie może być pusta!'
        redirect_to conversation_path(@conversation)
      end
    end

    private

    def set_conversation
      @conversation = current_user.mailbox.conversations.find(params[:conversation_id])
    end
  end
end
