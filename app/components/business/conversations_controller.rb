module Business
  class ConversationsController < ApplicationController
    before_action :set_participant
    append_view_path 'app/components'

    def create
      @recipients = Business::SignUpRecord.where(id: params[:sign_up_ids])

      if params[:body].present? && params[:subject].present?
        receipt = @participant.send_message(@recipients, params[:body], params[:subject])

        redirect_to conversation_path(receipt.conversation)
      else
        flash[:alert] = 'Wypełnij temat i wybierz odbiorcę'
      end
    end

    private

    def set_participant
      @participant = if user_signed_in?
                      current_user
                    else
                      Business::SignUpRecord.find_by(code: params[:code])
                    end
    end
  end
end
