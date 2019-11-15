module Messaging
  class ConversationsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      @q = current_user.mailbox.conversations.ransack(params[:q])
      @q.sorts = 'created_at asc' if @q.sorts.empty?
      @conversations = @q.result(distinct: true)

      authorize! :read, Mailboxer::Conversation
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
      recipient = Db::User.find(params[:user_id])
      if recipient && params[:body].present? && params[:subject]
        receipt = current_user.send_message(recipient, params[:body], params[:subject])
        redirect_to conversation_path(receipt.conversation)
      else
        render :new
      end
    end
  end
end
