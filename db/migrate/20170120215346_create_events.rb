class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :name
      t.string :place
      t.date :event_date
      t.integer :manager_kw_id
      t.string :participants
      t.string :application_list_url
      t.integer :price_for_members
      t.integer :price_for_non_members
      t.date :application_date
      t.date :payment_date
      t.string :account_number
      t.string :event_rules_url
      t.string :google_group_discussion_url
      t.timestamps
    end
  end
end
