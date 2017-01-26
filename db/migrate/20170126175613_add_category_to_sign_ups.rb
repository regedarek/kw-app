class AddCategoryToSignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :strzelecki_sign_ups, :category_type, :integer, default: 0
    add_column :strzelecki_sign_ups, :package_type, :integer, default: 0
  end
end
