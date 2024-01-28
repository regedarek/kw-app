class AddArchivedToSaleAnnouncements < ActiveRecord::Migration[5.2]
  def change
    add_column :sale_announcements, :archived, :boolean, null: false, default: false
  end
end
