class AddSlugToMarketingDiscounts < ActiveRecord::Migration[5.2]
  def change
    add_column :marketing_discounts, :slug, :string
  end
end
