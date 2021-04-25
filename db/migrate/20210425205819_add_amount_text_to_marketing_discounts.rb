class AddAmountTextToMarketingDiscounts < ActiveRecord::Migration[5.2]
  def change
    add_column :marketing_discounts, :amount_text, :string
  end
end
