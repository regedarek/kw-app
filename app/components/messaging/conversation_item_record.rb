# == Schema Information
#
# Table name: messaging_conversation_items
#
#  id               :bigint           not null, primary key
#  messageable_type :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  conversation_id  :integer          not null
#  messageable_id   :integer          not null
#
# Indexes
#
#  index_messaging_conversation_items_on_conversation_id  (conversation_id)
#  messageable_conversations                              (messageable_type,messageable_id)
#
module Messaging
  class ConversationItemRecord < ActiveRecord::Base
    self.table_name = 'messaging_conversation_items'

    belongs_to :conversation, class_name: "Mailboxer::Conversation", foreign_key: :conversation_id
    belongs_to :messageable, polymorphic: true
  end
end
