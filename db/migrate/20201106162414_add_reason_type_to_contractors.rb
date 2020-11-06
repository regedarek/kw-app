class AddReasonTypeToContractors < ActiveRecord::Migration[5.2]
  def change
    add_column :contractors, :reason_type, :integer, default: 0, null: false
  end
end
