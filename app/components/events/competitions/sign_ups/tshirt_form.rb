require 'dry-validation'
require 'dry-types'
Dry::Types.load_extensions(:maybe)
module Types
  include Dry.Types(default: :nominal)
end

module Events
  module Competitions
    module SignUps
      class TshirtForm < Dry::Validation::Contract
        option :competition_id

        params do
         required(:participant_name_1).filled(:string)
         required(:tshirt_size_1).filled(:string)
         required(:competition_package_type_1_id).filled(:integer)
         optional(:participant_phone_1).maybe(:string)
         optional(:participant_kw_id_1).maybe(:integer)
        end

        rule(:participant_kw_id_1, :competition_package_type_1_id) do
          package_id = values[:competition_package_type_1_id]
          kw_id = values[:participant_kw_id_1]
          
          if Events::Db::CompetitionPackageTypeRecord.find(package_id).membership?
            unless ::Membership::Activement.new(user: ::Db::User.find_by(kw_id: kw_id)).active?
              key.failure('must be an active member')
            end
          end
        end
      end
    end
  end
end
