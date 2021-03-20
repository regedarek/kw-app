class AddStateToSettlementProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :settlement_projects, :state, :string, null: false, default: 'open'
  end
end
