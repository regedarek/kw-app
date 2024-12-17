# == Schema Information
#
# Table name: competition_package_types
#
#  id                    :integer          not null, primary key
#  cost                  :integer          not null
#  junior_year           :integer
#  membership            :boolean          default(FALSE), not null
#  name                  :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  competition_record_id :integer          not null
#
module Events
  module Db
    class CompetitionPackageTypeRecord < ActiveRecord::Base
      self.table_name = 'competition_package_types'

      belongs_to :competition,
        foreign_key: :competition_record_id,
        class_name: 'Events::Db::CompetitionRecord',
        inverse_of: :package_types
    end
  end
end
