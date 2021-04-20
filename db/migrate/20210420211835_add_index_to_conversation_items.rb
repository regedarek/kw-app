class AddIndexToConversationItems < ActiveRecord::Migration[5.2]
  def change
    add_index :messaging_conversation_items, [:messageable_type, :messageable_id], name: 'messageable_conversations'
    add_index :messaging_conversation_items, :conversation_id
  end
end
