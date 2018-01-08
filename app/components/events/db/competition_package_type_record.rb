module Events
  module Db
    class CompetitionPackageTypeRecord < ActiveRecord::Base
      self.table_name = 'competition_package_types'

      belongs_to :competition, class_name: 'Events::Db::CompetitionRecord'
    end
  end
end
