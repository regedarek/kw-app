class AddCategoryToRequestYearlyPrize < ActiveRecord::Migration[5.2]
  def change
    add_column :yearly_prize_requests, :yearly_prize_category_id, :integer, null: false
    add_index :yearly_prize_requests, :yearly_prize_category_id
  end
end
