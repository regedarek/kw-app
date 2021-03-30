class CreateManagementResolutions < ActiveRecord::Migration[5.2]
  def change
    create_table :management_resolutions do |t|
      t.string :name, null: false
      t.text :description
      t.string :slug, null: false
      t.timestamps
    end
  end
end
