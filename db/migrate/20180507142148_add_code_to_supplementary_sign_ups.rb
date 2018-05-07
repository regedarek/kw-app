class AddCodeToSupplementarySignUps < ActiveRecord::Migration[5.0]
  def change
    add_column :supplementary_sign_ups, :code, :string, null: false, default: SecureRandom.hex(8), unique: true
  end
end
