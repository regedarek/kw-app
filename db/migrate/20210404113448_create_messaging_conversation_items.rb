class CreateMessagingConversationItems < ActiveRecord::Migration[5.2]
  def change
    create_table :messaging_conversation_items do |t|
      t.integer :conversation_id, null: false
      t.string :messageable_type, null: false
      t.integer :messageable_id, null: false
      t.timestamps
    end

    add_index :messaging_conversation_items, [:messageable_type, :messageable_id], unique: true, name: 'messaging_conversation_items_uniq'
  end
end
