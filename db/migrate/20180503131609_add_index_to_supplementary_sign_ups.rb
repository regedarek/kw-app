class AddIndexToSupplementarySignUps < ActiveRecord::Migration[5.0]
  def change
    add_index(:supplementary_sign_ups, [:course_id, :user_id], unique: true)
  end
end
