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

      def closed_or_limit_reached?
        closed? || limit_reached?
      end

      def limit_reached?
        return false if limit == 0

        sign_ups_records.count >= limit
      end
    end
  end
end
