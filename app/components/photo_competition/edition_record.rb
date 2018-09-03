module PhotoCompetition
  class EditionRecord < ActiveRecord::Base
    self.table_name = 'photo_competitions'
    has_many :photo_requests, dependent: :destroy, class_name: '::PhotoCompetition::RequestRecord'
  end
end
