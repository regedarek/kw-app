class AddFieldsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :needed_knowledge, :text
    add_column :projects, :benefits, :text
    add_column :projects, :estimated_time, :text
    add_column :projects, :attachments, :string
    add_column :projects, :know_how, :text
  end
end
