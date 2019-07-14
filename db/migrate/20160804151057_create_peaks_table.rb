class CreatePeaksTable < ActiveRecord::Migration[5.0]
  def change
    create_table :peaks do |t|
      t.string :name
      t.integer :valley_id
    end
  end
end
