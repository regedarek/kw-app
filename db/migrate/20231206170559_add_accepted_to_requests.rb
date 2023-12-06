class AddAcceptedToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :yearly_prize_requests, :accepted, :boolean, default: false
  end
end
