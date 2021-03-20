class AddAreaTypeToSettlementProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :settlement_projects, :area_type, :integer, default: 0, null: false
  end
end
