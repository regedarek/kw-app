require 'dry-types'
require 'dry-struct'

Dry::Types.load_extensions(:maybe)
module Types
  include Dry.Types(default: :nominal)
end

module Events
  class SignUp < Dry::Struct
    transform_keys(&:to_sym)

    attribute :id, Types::Strict::Integer.optional
    attribute :team_name, Types::String.optional
    attribute :teammate_id, Types::Integer.optional
    attribute :competition_id, Types::Coercible::Integer
    attribute :participant_kw_id_1, Types::Coercible::Integer
    attribute :participant_kw_id_2, Types::Coercible::Integer
    attribute :participant_first_name_1, Types::String
    attribute :participant_name_1, Types::String
    attribute :participant_name_2, Types::String
    attribute :participant_email_1, Types::String
    attribute :participant_email_2, Types::String
    attribute :participant_birth_year_1, Types::Coercible::Integer
    attribute :participant_birth_year_2, Types::Coercible::Integer
    attribute :participant_city_1, Types::String
    attribute :participant_city_2, Types::String
    attribute :participant_team_1, Types::String
    attribute :participant_team_2, Types::String
    attribute :tshirt_size_1, Types::String.optional
    attribute :tshirt_size_2, Types::String.optional
    attribute :participant_gender_1, Types::Coercible::Integer
    attribute :participant_gender_2, Types::Coercible::Integer
    attribute :competition_package_type_1_id, Types::Coercible::Integer
    attribute :competition_package_type_2_id, Types::Coercible::Integer
    attribute :remarks, Types::String.optional
    attribute :terms_of_service, Types::Bool.default(false)
    attribute :single, Types::Bool

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

    def payment
      if id
        Events::Db::SignUpRecord.find(id).payment
      else
        nil
      end
    end

    class << self
      def from_record(record)
        new(
          id: record.id,
          teammate_id: record.teammate_id,
          competition_id: record.competition_record_id,
          participant_kw_id_1: record.participant_kw_id_1,
          participant_kw_id_2: record.participant_kw_id_2,
          participant_first_name_1: record.participant_first_name_1,
          participant_name_1: record.participant_name_1,
          participant_name_2: record.participant_name_2,
          participant_email_1: record.participant_email_1,
          participant_email_2: record.participant_email_2,
          participant_birth_year_1: record.participant_birth_year_1,
          participant_birth_year_2: record.participant_birth_year_2,
          participant_city_1: record.participant_city_1,
          participant_city_2: record.participant_city_2,
          participant_team_1: record.participant_team_1,
          participant_team_2: record.participant_team_2,
          participant_gender_1: record.participant_gender_1,
          participant_gender_2: record.participant_gender_2,
          competition_package_type_1_id: record.competition_package_type_1_id,
          competition_package_type_2_id: record.competition_package_type_2_id,
          tshirt_size_1: record.tshirt_size_1,
          tshirt_size_2: record.tshirt_size_2,
          remarks: record.remarks,
          single: record.single
        )
      end
    end
  end
end
