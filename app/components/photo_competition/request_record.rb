module PhotoCompetition
  class RequestRecord < ActiveRecord::Base
    self.table_name = 'photo_requests'
    belongs_to :edition, class_name: '::PhotoCompetition::EditionRecord'
    belongs_to :user, class_name: 'Db::User'
  end
end
