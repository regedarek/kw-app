class AddPathToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :path, :string
  end
end
