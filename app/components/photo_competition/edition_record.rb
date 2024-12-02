# == Schema Information
#
# Table name: photo_competitions
#
#  id                :integer          not null, primary key
#  closed            :boolean          default(FALSE), not null
#  code              :string           not null
#  end_voting_date   :datetime
#  name              :string           not null
#  start_voting_date :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
module PhotoCompetition
  class EditionRecord < ActiveRecord::Base
    self.table_name = 'photo_competitions'
    has_many :photo_requests, dependent: :destroy, class_name: '::PhotoCompetition::RequestRecord'
    has_many :categories, dependent: :destroy, class_name: '::PhotoCompetition::CategoryRecord'
  end
end
