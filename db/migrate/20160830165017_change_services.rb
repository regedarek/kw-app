class ChangeServices < ActiveRecord::Migration
  def change
    rename_column :services, :order_id, :serviceable_id
    rename_column :services, :type, :serviceable_type
  end
end
