class AddEquipmentAtToBusinessSignUps < ActiveRecord::Migration[5.2]
  def change
    add_column :business_sign_ups, :equipment_at, :datetime
  end
end
