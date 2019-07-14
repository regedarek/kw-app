class ChangeColumnName < ActiveRecord::Migration[5.0]
  def change
    rename_column :payments, :user_id, :kw_id
  end
end
