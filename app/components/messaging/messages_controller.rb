module Messaging
  class MessagesController < ApplicationController
    before_action :set_participant
    before_action :set_conversation

    def create
      return redirect_to(conversation_path(@conversation), alert: 'Nie jesteś uczestnikiem!') unless @participant

      if params[:body].present?
        receipt = @participant.reply_to_conversation(@conversation, params[:body])
        redirect_to conversation_path(@conversation)
      else
        flash[:alert] = 'Odpowiedź nie może być pusta!'
        redirect_to conversation_path(@conversation)
      end
    end

    private

    def set_conversation
      @conversation = @participant.mailbox.conversations.find(params[:conversation_id])
    end

    def set_participant
      @participant = if user_signed_in?
                      current_user
                    else
                      Business::SignUpRecord.find_by(code: params[:code])
                    end
    end
  end
end
