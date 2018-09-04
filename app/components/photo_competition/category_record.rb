module PhotoCompetition
  class CategoryRecord < ActiveRecord::Base
    self.table_name = 'edition_categories'
    belongs_to :edition, class_name: '::PhotoCompetition::EditionRecord'
    has_many :photos, class_name: '::PhotoCompetition::RequestRecord'
  end
end
