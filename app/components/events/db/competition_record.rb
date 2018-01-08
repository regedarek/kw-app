module Events
  module Db
    class CompetitionRecord < ActiveRecord::Base
      self.table_name = 'competitions'

      has_many :sign_ups_records,
        class_name: 'Events::Db::SignUpRecord',
        dependent: :destroy
      has_many :package_types,
        class_name: 'Events::Db::CompetitionPackageTypeRecord',
        dependent: :destroy
    end
  end
end
