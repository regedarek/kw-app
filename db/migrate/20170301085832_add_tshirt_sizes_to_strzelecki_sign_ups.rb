class AddTshirtSizesToStrzeleckiSignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :strzelecki_sign_ups, :tshirt_size_1, :integer
    add_column :strzelecki_sign_ups, :tshirt_size_2, :integer
  end
end
