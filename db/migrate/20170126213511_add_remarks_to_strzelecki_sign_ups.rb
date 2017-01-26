class AddRemarksToStrzeleckiSignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :strzelecki_sign_ups, :remarks, :text
  end
end
