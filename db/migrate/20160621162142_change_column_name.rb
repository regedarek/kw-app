class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :payments, :user_id, :kw_id
  end
end
