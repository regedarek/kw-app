module Business
  class ConversationsController < ApplicationController
    append_view_path 'app/components'

    def create
      if params[:body].present? && params[:subject].present?
        recipient = Business::SignUpRecord.find(params[:recipient_id])
        receipt = current_user.send_message(recipient, params[:body], params[:subject])
        receipt.conversation.sign_ups << recipient

        redirect_to conversation_path(receipt.conversation)
      else
        flash[:alert] = 'Wypełnij temat i wybierz odbiorcę'
      end
    end
  end
end
