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
      validates_acceptance_of :terms_of_service
      has_many :emails, as: :mailable, class_name: 'EmailCenter::EmailRecord', dependent: :destroy

      def gender_1
        if participant_gender_1 == 1
          'Mężczyzna'
        else
          'Kobieta'
        end
      end

      def gender_2
        if participant_gender_2 == 1
          'Mężczyzna'
        else
          'Kobieta'
        end
      end

      def package_type_1_membership?
        return false unless Events::Db::CompetitionPackageTypeRecord.exists?(competition_package_type_1_id)
        Events::Db::CompetitionPackageTypeRecord.find(competition_package_type_1_id).membership
      end

      def package_type_2_membership?
        return false unless Events::Db::CompetitionPackageTypeRecord.exists?(competition_package_type_2_id)
        Events::Db::CompetitionPackageTypeRecord.find(competition_package_type_2_id).membership
      end

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
