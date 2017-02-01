class AddPhoneToStrzeleckiSignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :strzelecki_sign_ups, :phone_1, :string
    add_column :strzelecki_sign_ups, :phone_2, :string
  end
end
