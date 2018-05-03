class CreateSupplementarySignUps < ActiveRecord::Migration[5.0]
  def change
    create_table :supplementary_sign_ups do |t|
      t.integer :user_id
      t.integer :course_id
      t.integer :payment_id
      t.timestamps
    end
  end
end
