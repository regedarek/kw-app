class CreateMasSignUps < ActiveRecord::Migration[5.0]
  def change
    create_table :mas_sign_ups do |t|
      t.string :name_1
      t.string :name_2
      t.string :email_1
      t.string :email_2
      t.string :organization_1
      t.string :organization_2
      t.string :city_1
      t.string :city_2
      t.integer :package_type_1
      t.integer :package_type_2
      t.integer :gender_1
      t.integer :gender_2
      t.string :phone_1
      t.string :phone_2
      t.integer :tshirt_size_1
      t.integer :tshirt_size_2
      t.text :remarks
      t.integer :birth_year_1
      t.integer :birth_year_2
      t.timestamps
    end
  end
end
