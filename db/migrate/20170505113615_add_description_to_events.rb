class AddDescriptionToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :descrption, :text
  end
end
