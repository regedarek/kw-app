class AddAcceptedAtToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :accepted_at, :datetime
  end
end
