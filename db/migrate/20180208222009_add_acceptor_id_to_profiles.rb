class AddAcceptorIdToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :acceptor_id, :integer
  end
end
