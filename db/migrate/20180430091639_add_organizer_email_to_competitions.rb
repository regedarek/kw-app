class AddOrganizerEmailToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :organizer_email, :string, default: 'kw@kw.krakow.pl', null: false
  end
end
