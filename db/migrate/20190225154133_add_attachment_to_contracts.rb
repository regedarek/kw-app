class AddAttachmentToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :attachments, :string
  end
end
