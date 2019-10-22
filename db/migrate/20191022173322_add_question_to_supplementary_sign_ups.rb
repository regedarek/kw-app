class AddQuestionToSupplementarySignUps < ActiveRecord::Migration[5.2]
  def change
    add_column :supplementary_sign_ups, :question, :string
  end
end
