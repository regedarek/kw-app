class AddAttachmentsToManagementInformations < ActiveRecord::Migration[5.2]
  def change
    add_column :management_informations, :attachments, :string
  end
end
