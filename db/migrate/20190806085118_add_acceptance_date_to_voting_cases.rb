class AddAcceptanceDateToVotingCases < ActiveRecord::Migration[5.2]
  def change
    add_column :management_cases, :acceptance_date, :date
  end
end
