class AddCerberIdToCasePresences < ActiveRecord::Migration[5.2]
  def change
    add_column :case_presences, :cerber_id, :integer
  end
end
