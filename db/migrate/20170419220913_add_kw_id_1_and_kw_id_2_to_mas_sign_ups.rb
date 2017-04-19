class AddKwId1AndKwId2ToMasSignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :mas_sign_ups, :kw_id_1, :integer
    add_column :mas_sign_ups, :kw_id_2, :integer
  end
end
