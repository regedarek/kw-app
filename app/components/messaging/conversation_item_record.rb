module Messaging
  class ConversationItemRecord < ActiveRecord::Base
    self.table_name = 'messaging_conversation_items'

    belongs_to :conversation, class_name: "Mailboxer::Conversation", foreign_key: :conversation_id
    belongs_to :messageable, polymorphic: true
  end
end
