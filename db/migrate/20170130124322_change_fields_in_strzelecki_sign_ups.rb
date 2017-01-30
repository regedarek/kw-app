class ChangeFieldsInStrzeleckiSignUps < ActiveRecord::Migration[5.0]
  def change
    change_table :strzelecki_sign_ups do |t|
      t.rename :names, :name_1
      t.rename :birth_year, :birth_year_1
      t.rename :team, :single
      t.rename :vege, :vege_1
    end
    add_column :strzelecki_sign_ups, :name_2, :string
    add_column :strzelecki_sign_ups, :birth_year_2, :string
    add_column :strzelecki_sign_ups, :vege_2, :boolean, default: false
  end
end
