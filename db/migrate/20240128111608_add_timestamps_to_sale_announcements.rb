class AddTimestampsToSaleAnnouncements < ActiveRecord::Migration[5.2]
  def change
    add_column :sale_announcements, :created_at, :datetime, null: false
    add_column :sale_announcements, :updated_at, :datetime, null: false
  end
end
