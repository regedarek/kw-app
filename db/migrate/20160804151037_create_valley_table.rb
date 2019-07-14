class CreateValleyTable < ActiveRecord::Migration[5.0]
  def change
    create_table :valleys do |t|
      t.string :name
    end
  end
end
