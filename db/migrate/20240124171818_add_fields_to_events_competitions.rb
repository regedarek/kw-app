class AddFieldsToEventsCompetitions < ActiveRecord::Migration[5.2]
  def change
    add_column :competitions, :en_email_text, :text
    add_column :competitions, :custom_form, :string
  end
end
