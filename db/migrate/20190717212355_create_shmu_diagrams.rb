class CreateShmuDiagrams < ActiveRecord::Migration[5.2]
  def change
    create_table :shmu_diagrams do |t|
      t.datetime :diagram_time
      t.string :place
      t.string :image
      t.timestamps
    end
  end
end
