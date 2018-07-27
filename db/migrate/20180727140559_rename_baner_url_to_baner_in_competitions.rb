class RenameBanerUrlToBanerInCompetitions < ActiveRecord::Migration[5.0]
  def change
    rename_column :competitions, :baner_url, :baner
  end
end
