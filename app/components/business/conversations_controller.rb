module Business
  class ConversationsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def create
      if params[:body].present? && params[:subject].present?
        receipt = current_user.send_message(recipient, params[:body], params[:subject])

        redirect_to conversation_path(receipt.conversation)
      else
        flash[:alert] = 'Wypełnij temat i wybierz odbiorcę'
      end
    end
  end
end
