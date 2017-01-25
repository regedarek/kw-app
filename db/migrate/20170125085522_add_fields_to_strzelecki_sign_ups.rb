class AddFieldsToStrzeleckiSignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :strzelecki_sign_ups, :organization, :string
    add_column :strzelecki_sign_ups, :vege, :boolean, default: false
    add_column :strzelecki_sign_ups, :birth_year, :integer
  end
end
