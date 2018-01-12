require 'dry-validation'
require 'dry-types'
Dry::Types.load_extensions(:maybe)
module Types
  include Dry::Types.module

end

module Events
  module Competitions
    module SignUps
      class CreateForm < Dry::Validation::Schema::Form
        configure do
          config.messages_file = 'app/components/events/competitions/sign_ups/errors.yml'
          config.type_specs = true
        end

        define! do
          if optional(:single).value(:false?)
            required(:participant_name_2, Types::String).filled
            required(:participant_email_2, Types::String).filled(format?: /.@.+[.][a-z]{2,}/i)
            required(:participant_birth_year_2, Types::Form::Int).filled(:int?, lt?: 2003, gt?: 1920)
            required(:competition_package_type_2_id, Types::Form::Int).filled
            optional(:participant_kw_id_2, Types::Form::Int).maybe

            validate(active_kw_id: [:participant_kw_id_2, :competition_package_type_2_id]) do |kw_id, package_id|
              if Events::Db::CompetitionPackageTypeRecord.find(package_id).membership?
                ::Db::Membership::Fee.exists?(year: Date.today.year, kw_id: kw_id)
              else
                true
              end
            end
          end

         required(:participant_name_1, Types::String).filled
         required(:participant_email_1, Types::String).filled(:str?, format?: /.@.+[.][a-z]{2,}/i)
         required(:participant_birth_year_1, Types::Form::Int).filled(:int?, lt?: 2003, gt?: 1920)
         required(:competition_package_type_1_id, Types::Form::Int).filled
         optional(:participant_kw_id_1, Types::Form::Int).maybe
         required(:terms_of_service, Types::Form::Bool).value(:true?)

         validate(active_kw_id: [:participant_kw_id_1, :competition_package_type_1_id]) do |kw_id, package_id|
           if Events::Db::CompetitionPackageTypeRecord.find(package_id).membership?
             ::Db::Membership::Fee.exists?(year: Date.today.year, kw_id: kw_id)
           else
             true
           end
         end
        end
      end
    end
  end
end
