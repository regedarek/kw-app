require 'dry-validation'
require 'dry-types'
Dry::Types.load_extensions(:maybe)
module Types
  include Dry::Types.module
end

module Events
  module Competitions
    module SignUps
      class TshirtForm < Dry::Validation::Schema
        configure do
          config.messages = :i18n
          config.messages_file = 'app/components/events/competitions/sign_ups/errors.yml'
          config.type_specs = true
        end
        configure { option :competition_id }

        define! do
         required(:participant_name_1).filled
         required(:tshirt_size_1).filled
         required(:competition_package_type_1_id).filled
         optional(:participant_phone_1).maybe(:str?)

         validate(active_kw_id_1: [:participant_kw_id_1, :competition_package_type_1_id]) do |kw_id, package_id|
           if Events::Db::CompetitionPackageTypeRecord.find(package_id).membership?
             ::Membership::Activement.new(user: ::Db::User.find_by(kw_id: kw_id)).active?
           else
             true
           end
         end
        end
      end
    end
  end
end
