module Events
  module Db
    class SignUpRecord < ActiveRecord::Base
      self.table_name = 'events_sign_ups'

      enum participant_country_1: [:pl, :sk], _prefix: :country_1
      enum participant_country_2: [:pl, :sk], _prefix: :country_2

      has_one :payment,
        as: :payable,
        dependent: :destroy,
        class_name: 'Db::Payment'
      belongs_to :competition_record,
        class_name: 'Events::Db::CompetitionRecord'
      validates_acceptance_of :terms_of_service
      validates_acceptance_of :medical_rules
      has_many :emails, as: :mailable, class_name: 'EmailCenter::EmailRecord', dependent: :destroy

      def sport_category_1
        return nil unless participant_birth_year_1.present?

        case
        when participant_birth_year_1.to_i.between?(2005, 2006)
          if participant_gender_1 == 1
            "Junior Młodszy (U18)"
          else
            "Juniorka Młodsza (U18)"
          end
        when participant_birth_year_1.to_i.between?(2003, 2004)
          if participant_gender_1 == 1
            "Junior (U20)"
          else
            "Juniorka (U20)"
          end
        when participant_birth_year_1.to_i.between?(1974, 2002)
          if participant_gender_1 == 1
            "Senior"
          else
            "Seniorka"
          end
        when participant_birth_year_1.to_i.between?(1900, 1973)
          if participant_gender_1 == 1
            "Nestor"
          else
            "Nestorka"
          end
        else
          "ERROR"
        end
      end

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
