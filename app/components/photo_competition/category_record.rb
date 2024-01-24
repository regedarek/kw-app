# == Schema Information
#
# Table name: edition_categories
#
#  id                :integer          not null, primary key
#  mandatory_fields  :text             default([]), is an Array
#  name              :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  edition_record_id :integer          not null
#
module PhotoCompetition
  class CategoryRecord < ActiveRecord::Base
    self.table_name = 'edition_categories'
    belongs_to :edition, class_name: '::PhotoCompetition::EditionRecord'
    has_many :photos, class_name: '::PhotoCompetition::RequestRecord'
  end
end
