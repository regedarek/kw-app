require 'dry-validation'

module Events
  module Competitions
    module SignUps
      CreateForm = Dry::Validation.Form do
        configure do
          config.messages_file = 'app/components/events/competitions/sign_ups/errors.yml'

          def email?(value)
            ! /^(([A-Za-z0-9]*\.+*_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\+)|([A-Za-z0-9]+\+))*[A-Z‌​a-z0-9]+@{1}((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,4}$/i.match(value).nil?
          end
        end
        required(:single).filled(:bool?).when(:false?) do
          required(:participant_email_2).filled(:str?, :email?)
          required(:participant_name_2).filled(:str?)
          required(:participant_birth_year_2).filled(:int?, lt?: 2003, gt?: 1920)
          required(:competition_package_type_2_id).filled(:str?)
        end

        required(:participant_name_1).filled(:str?)
        required(:participant_email_1).filled(:str?, :email?)
        required(:participant_birth_year_1).filled(:int?, lt?: 2003, gt?: 1920)
        required(:competition_package_type_1_id).filled(:str?)
        required(:terms_of_service).filled(eql?: '1')
      end
    end
  end
end
