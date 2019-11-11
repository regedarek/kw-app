class AddToprDegreeToToprRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :topr_records, :topr_degree, :string
  end
end
