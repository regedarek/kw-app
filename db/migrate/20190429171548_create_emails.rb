class CreateEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :emails do |t|
      t.string :message_id, null: false
      t.datetime :delivered_at
      t.integer :mailable_id, null: false
      t.string :mailable_type, null: false
      t.string :state, default: 'sent'
      t.timestamps
    end
  end
end
