module Messaging
  class ConversationsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      authorize! :read, Mailboxer::Conversation

      @q = current_user.mailbox.conversations.ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty?
      @conversations = @q.result(distinct: true).page(params[:page]).per(10)
    end

    def show
      authorize! :read, Mailboxer::Conversation

      @conversation = current_user.mailbox.conversations.find(params[:id])
      @users = Db::User.where.not(kw_id: nil).not_hidden.active - @conversation.participants
    end

    def add_participant
      authorize! :create, Mailboxer::Conversation

      conversation = current_user.mailbox.conversations.find(params[:id])
      participant = Db::User.find_by(id: params[:user_id])

      if conversation.participants.any?(participant)
        redirect_to conversation_path(conversation.id), alert: 'Uczestnik już został dodany!'
      else
        messages = conversation.add_participant(participant)
        redirect_to conversation_path(conversation.id), notice: 'Dodano uczestnika!'
        ::Messaging::Mailers::MessageMailer.add_participant(messages.first, participant).deliver_later if messages.any?
      end
    end

    def new
      authorize! :create, Mailboxer::Conversation

      @users = Db::User.where.not(kw_id: nil).not_hidden.active - [current_user]
    end

    def create
      authorize! :create, Mailboxer::Conversation

      @users = Db::User.where.not(kw_id: nil).not_hidden.active - [current_user]
      @recipients = Db::User.where(id: params[:user_ids])

      if @recipients.any? && params[:body].present? && params[:subject].present?
        receipt = current_user.send_message(@recipients, params[:body], params[:subject])
        redirect_to conversation_path(receipt.conversation), notice: 'Wysłano wiadomość'
      else
        flash[:alert] = 'Wypełnij temat i wybierz odbiorców!'
        render :new
      end
    end
  end
end
