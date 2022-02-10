class AddSignUpStartsAtToCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :sign_up_starts_at, :datetime
  end
end
