class AddVotableToYearlyPrizeEditions < ActiveRecord::Migration[5.2]
  def change
    add_column :yearly_prize_editions, :votable, :boolean, default: false, null: false
  end
end
