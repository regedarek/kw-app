class CreateManagementInformations < ActiveRecord::Migration[5.2]
  def change
    create_table :management_informations do |t|
      t.string :name, null: false
      t.text :description
      t.string :url
      t.integer :news_type, null: false, default: 0
      t.timestamps
    end
  end
end
