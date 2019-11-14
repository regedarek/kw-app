module Messaging
  class ConversationsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      @q = current_user.mailbox.conversations.ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty?
      @conversations = @q.result(distinct: true)
    end

    def show
      @conversation = current_user.mailbox.conversations.find(params[:id])
    end

    def new
      @recipients = Db::User.all - [current_user]
    end

    def create
      recipient = Db::User.find(params[:user_id])
      receipt   = current_user.send_message(recipient, params[:body], params[:subject])
      redirect_to conversation_path(receipt.conversation)
    end
  end
end
