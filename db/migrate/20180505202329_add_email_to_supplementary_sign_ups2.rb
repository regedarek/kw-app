class AddEmailToSupplementarySignUps2 < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_sign_ups, :email, :string, unique: true
  end
end
