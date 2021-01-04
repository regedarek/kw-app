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
      @conversation = current_user.mailbox.conversations.find(params[:id])

      authorize! :read, Mailboxer::Conversation
    end

    def new
      @recipients = Db::User.where.not(kw_id: nil).not_hidden.active - [current_user]

      authorize! :create, Mailboxer::Conversation
    end

    def create
      @recipients = Db::User.where.not(kw_id: nil).not_hidden.active - [current_user]
      recipient = Db::User.find_by(id: params[:user_id])

      if recipient && params[:body].present? && params[:subject].present?
        receipt = current_user.send_message(recipient, params[:body], params[:subject])
        redirect_to conversation_path(receipt.conversation)
      else
        flash[:alert] = 'Wypełnij temat i wybierz odbiorcę'
        render :new
      end
    end
  end
end
