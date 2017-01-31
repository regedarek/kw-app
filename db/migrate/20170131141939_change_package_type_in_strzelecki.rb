class ChangePackageTypeInStrzelecki < ActiveRecord::Migration[5.0]
  def change
    change_table :strzelecki_sign_ups do |t|
      t.rename :package_type, :package_type_1
    end
    add_column :strzelecki_sign_ups, :package_type_2, :integer, default: 0
  end
end
