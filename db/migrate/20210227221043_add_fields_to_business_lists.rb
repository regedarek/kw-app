class AddFieldsToBusinessLists < ActiveRecord::Migration[5.2]
  def change
    add_column :business_lists, :birthdate, :date
    add_column :business_lists, :birthplace, :string
    add_column :business_lists, :alternative_email, :string
  end
end
