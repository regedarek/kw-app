class AddAttachmentsToRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :yearly_prize_requests, :attachments, :string
  end
end
