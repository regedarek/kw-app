class UpdateMasSignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :mas_sign_ups, :name, :string
    rename_column :mas_sign_ups, :name_1, :first_name_1
    rename_column :mas_sign_ups, :name_2, :first_name_2
    add_column :mas_sign_ups, :last_name_1, :string
    add_column :mas_sign_ups, :last_name_2, :string
  end
end
