class CreateContractTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :contract_templates do |t|
      t.string :name
      t.integer :group_type
      t.integer :payout_type
      t.integer :financial_type
      t.integer :document_type
      t.integer :event_type
      t.integer :substantive_type
      t.integer :area_type
      t.integer :activity_type
      t.integer :checker_id

      t.timestamps
    end
  end
end
