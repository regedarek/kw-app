class CreateContractTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :contract_templates do |t|
      t.string :name
      t.string :group_type
      t.string :payout_type
      t.string :financial_type
      t.string :document_type
      t.string :event_type
      t.string :substantive_type
      t.string :area_type
      t.string :activity_type
      t.integer :checker_id

      t.timestamps
    end
  end
end
