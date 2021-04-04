module Messaging
  class ConversationsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      authorize! :read, Mailboxer::Conversation

      @q = current_user.mailbox.conversations.ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty?
      @conversations = @q.result(distinct: true)
    end

    def show
      authorize! :read, Mailboxer::Conversation

      @conversation = current_user.mailbox.conversations.find(params[:id])
    end

    def new
      authorize! :create, Mailboxer::Conversation

      @users = Db::User.where.not(kw_id: nil).not_hidden.active - [current_user]
    end

    def create
      authorize! :create, Mailboxer::Conversation

      @users = Db::User.where.not(kw_id: nil).not_hidden.active - [current_user]
      @recipients = Db::User.where(id: params[:user_ids])

      if @recipients.any? && params[:user_ids] && params[:body].present? && params[:subject].present?
        receipt = current_user.send_message(@recipients, params[:body], params[:subject])
        redirect_to conversation_path(receipt.conversation)
      else
        flash[:alert] = 'Wypełnij temat i wybierz odbiorcę'
        render :new
      end
    end
  end
end
