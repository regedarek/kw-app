class AddAttachmentsToManagementCases < ActiveRecord::Migration[5.2]
  def change
    add_column :management_cases, :attachments, :string
  end
end
