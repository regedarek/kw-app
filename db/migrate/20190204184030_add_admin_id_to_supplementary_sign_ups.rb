class AddAdminIdToSupplementarySignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_sign_ups, :admin_id, :integer
  end
end
