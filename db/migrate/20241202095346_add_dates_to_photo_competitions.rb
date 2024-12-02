class AddDatesToPhotoCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :photo_competitions, :start_voting_date, :datetime
    add_column :photo_competitions, :end_voting_date, :datetime

    add_column :yearly_prize_editions, :start_voting_date, :datetime
    add_column :yearly_prize_editions, :end_voting_date, :datetime
  end
end
