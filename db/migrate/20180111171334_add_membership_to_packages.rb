class AddMembershipToPackages < ActiveRecord::Migration[5.0]
  def change
    add_column :competition_package_types, :membership, :boolean, null: false, default: false
  end
end
