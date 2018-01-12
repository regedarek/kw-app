class AddBanerUrlToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :baner_url, :string
    add_column :competitions, :rules, :string
  end
end
