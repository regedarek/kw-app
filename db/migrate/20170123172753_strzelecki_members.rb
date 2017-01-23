class StrzeleckiMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :strzelecki_sign_ups do |t|
      t.string :names
      t.string :email
      t.boolean :team, default: false
      t.timestamps
    end
  end
end
