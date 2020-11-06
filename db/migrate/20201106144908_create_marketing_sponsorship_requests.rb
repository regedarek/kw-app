class CreateMarketingSponsorshipRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :marketing_sponsorship_requests do |t|
      t.integer :user_id, null: false
      t.integer :contractor_id, null: false
      t.string :description
      t.string :attachments
      t.string :state, default: 'draft', null: false
      t.datetime :sent_at
      t.timestamps
    end
  end
end
