class ChangeDescriptionToRemarks < ActiveRecord::Migration[5.0]
  def change
    rename_column :reservations, :description, :remarks
  end
end
