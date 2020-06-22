class CreateTrainingExcercies < ActiveRecord::Migration[5.2]
  def change
    create_table :training_exercises do |t|
      t.string :name
      t.text :description
      t.integer :group_type
      t.timestamps
    end
  end
end
