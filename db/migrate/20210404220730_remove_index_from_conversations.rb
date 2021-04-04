class RemoveIndexFromConversations < ActiveRecord::Migration[5.2]
  def change
    remove_index :messaging_conversation_items, name: :messaging_conversation_items_uniq
  end
end
