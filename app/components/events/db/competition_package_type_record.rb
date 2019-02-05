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
