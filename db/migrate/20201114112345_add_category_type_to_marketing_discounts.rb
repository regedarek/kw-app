class AddCategoryTypeToMarketingDiscounts < ActiveRecord::Migration[5.2]
  def change
    add_column :marketing_discounts, :category_type, :integer
  end
end
