class CreateYearlyPrizeRequestUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :yearly_prize_request_users do |t|
      t.references :yearly_prize_request, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end
    remove_column :yearly_prize_requests, :user_id
  end
end
