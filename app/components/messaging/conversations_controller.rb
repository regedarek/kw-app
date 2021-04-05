module Messaging
  class ConversationsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      authorize! :read, Mailboxer::Conversation

      @q = current_user.mailbox.conversations.ransack(params[:q])
      @q.sorts = 'updated_at desc' if @q.sorts.empty?
      @conversations = @q.result(distinct: true).page(params[:page]).per(10)
    end

    def show
      authorize! :read, Mailboxer::Conversation

      @conversation = current_user.mailbox.conversations.find(params[:id])
      @users = Db::User.where.not(kw_id: nil).not_hidden.active - @conversation.participants - @conversation.opt_outs.map(&:unsubscriber)
    end

    def opt_in
      authorize! :create, Mailboxer::Conversation

      conversation = current_user.mailbox.conversations.find(params[:id])
      participant = Db::User.find_by(id: params[:user_id])

      conversation.opt_in(participant) if conversation && participant

      redirect_back(fallback_location: conversation_path(conversation.id), notice: 'Dopisałeś się!')
    end

    def opt_out
      authorize! :create, Mailboxer::Conversation

      conversation = current_user.mailbox.conversations.find(params[:id])
      participant = Db::User.find_by(id: params[:user_id])

      conversation.opt_out(participant) if conversation && participant

      redirect_back(fallback_location: conversation_path(conversation.id), notice: 'Wypisałeś się!')
    end

    def add_participant
      authorize! :create, Mailboxer::Conversation

      conversation = current_user.mailbox.conversations.find(params[:id])
      participant = Db::User.find_by(id: params[:user_id])

      if conversation.is_participant?(participant)
        redirect_to conversation_path(conversation.id), alert: 'Jesteś już uczestnikiem!'
      else
        messages = conversation.add_participant(participant)
        ::Messaging::Mailers::MessageMailer.add_participant(messages.first, participant).deliver_later if messages.any?
        redirect_to conversation_path(conversation.id), alert: 'Dodano uczestnika!'
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

        if params[:messageable_type].present? && params[:messageable_id].present?
          Messaging::ConversationItemRecord.create(
            conversation_id: receipt.conversation.id,
            messageable_type: params[:messageable_type],
            messageable_id: params[:messageable_id]
          )
        end

        redirect_to conversation_path(receipt.conversation), notice: 'Wysłano wiadomość'
      else
        flash[:alert] = 'Wypełnij temat i wybierz odbiorców!'
        render :new
      end
    end
  end
end
