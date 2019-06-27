class AddDocUrlToCases < ActiveRecord::Migration[5.2]
  def change
    add_column :management_cases, :doc_url, :string
  end
end
