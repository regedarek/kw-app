class CreateBusinessSignUps < ActiveRecord::Migration[5.2]
  def change
    create_table :business_sign_ups do |t|
      t.integer :user_id
      t.integer :course_id
      t.string :name
      t.string :email
      t.string :code, null: false, default: SecureRandom.hex(8), unique: true
      t.datetime :expired_at
      t.datetime :sent_at
      t.integer :admin_id
      t.string :question
      t.integer :send_user_id
      t.datetime :paid_email_sent_at
      t.timestamps
    end
  end
end
