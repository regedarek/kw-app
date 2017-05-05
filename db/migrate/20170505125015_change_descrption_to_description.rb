class ChangeDescrptionToDescription < ActiveRecord::Migration[5.0]
  def change
    rename_column :events, :descrption, :description
  end
end
