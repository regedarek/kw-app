class AddMandatoryFieldsToEditionCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :edition_categories, :mandatory_fields, :text, array: true, default: []
  end
end
