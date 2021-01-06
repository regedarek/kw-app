class AddLocaleToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :locale, :string, null: false, default: 'pl'
  end
end
