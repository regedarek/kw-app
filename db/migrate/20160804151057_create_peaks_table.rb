class CreatePeaksTable < ActiveRecord::Migration
  def change
    create_table :peaks do |t|
      t.string :name
      t.integer :valley_id
    end
  end
end
