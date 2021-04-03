class AddToCodesToMessaging < ActiveRecord::Migration[5.2]
  def change
    add_column :mailboxer_conversations, :code, :string, null: false, default: SecureRandom.hex(8), unique: true
  end
end
