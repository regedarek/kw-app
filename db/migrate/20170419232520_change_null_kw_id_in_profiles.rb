class ChangeNullKwIdInProfiles < ActiveRecord::Migration[5.0]
  def change
    change_column :profiles, :kw_id, :integer, null: true
  end
end
