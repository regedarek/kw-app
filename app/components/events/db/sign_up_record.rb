module Events
  module Db
    class SignUpRecord < ActiveRecord::Base
      self.table_name = 'events_sign_ups'

      has_one :payment,
        as: :payable,
        dependent: :destroy,
        class_name: 'Db::Payment'
      belongs_to :competition_record,
        class_name: 'Events::Db::CompetitionRecord'

      def package_type_1
        Events::Db::CompetitionPackageTypeRecord.find_by(id: competition_package_type_1_id)
      end

      def package_type_2
        Events::Db::CompetitionPackageTypeRecord.find_by(id: competition_package_type_2_id)
      end

      def package_types
        [package_type_1, package_type_2].compact
      end

      def cost
        package_types.map(&:cost).reduce(:+)
      end

      def payment_type
        :trainings
      end

      def description
        if single
          "Wpisowe nr #{id} na zawody #{competition_record.name} od #{participant_name_1}"
        else
          "Wpisowe nr #{id} na zawody #{competition_record.name} od #{participant_name_1} oraz #{participant_name_2}"
        end
      end
    end
  end
end
