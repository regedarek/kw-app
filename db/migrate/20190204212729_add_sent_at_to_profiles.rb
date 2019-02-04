class AddSentAtToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :sent_at, :datetime
  end
end
