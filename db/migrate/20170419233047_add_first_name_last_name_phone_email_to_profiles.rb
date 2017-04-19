class AddFirstNameLastNamePhoneEmailToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :first_name, :string
    add_column :profiles, :last_name, :string
    add_column :profiles, :email, :string
    add_column :profiles, :phone, :string
  end
end
