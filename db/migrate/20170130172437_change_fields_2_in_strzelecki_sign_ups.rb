class ChangeFields2InStrzeleckiSignUps < ActiveRecord::Migration[5.0]
  def change
    change_table :strzelecki_sign_ups do |t|
      t.rename :email, :email_1
      t.rename :organization, :organization_1
    end
    add_column :strzelecki_sign_ups, :email_2, :string
    add_column :strzelecki_sign_ups, :organization_2, :string
    add_column :strzelecki_sign_ups, :city_1, :string
    add_column :strzelecki_sign_ups, :city_2, :string
  end
end
