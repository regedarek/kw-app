class AddFieldsToBusinessSignUps < ActiveRecord::Migration[5.2]
  def change
    add_column :business_sign_ups, :phone, :string, null: false
    add_column :business_sign_ups, :birthdate, :date
    add_column :business_sign_ups, :birthplace, :string
    add_column :business_sign_ups, :alternative_email, :string
    add_column :business_sign_ups, :state, :string, null: false, default: 'new'
  end
end
