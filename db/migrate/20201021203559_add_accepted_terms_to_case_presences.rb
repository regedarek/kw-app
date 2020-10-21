class AddAcceptedTermsToCasePresences < ActiveRecord::Migration[5.2]
  def change
    add_column :case_presences, :accepted_terms, :boolean, default: false, null: false
  end
end
