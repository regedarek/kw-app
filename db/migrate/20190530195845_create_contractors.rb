class CreateContractors < ActiveRecord::Migration[5.2]
  def change
    create_table :contractors do |t|
      t.string :name
      t.string :nip
      t.text :description
      t.timestamps
    end
  end
end
