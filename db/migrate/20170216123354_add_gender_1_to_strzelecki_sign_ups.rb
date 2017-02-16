class AddGender1ToStrzeleckiSignUps < ActiveRecord::Migration[5.0]
  def change
    rename_column :strzelecki_sign_ups, :category_type, :gender_1
    add_column :strzelecki_sign_ups, :gender_2, :integer
  end
end
