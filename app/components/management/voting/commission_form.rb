require 'i18n'
require 'dry-validation'

module Management
  module Voting
    CommissionForm = Dry::Validation.Params do
      configure { config.messages_file = 'app/components/management/errors.yml' }
      configure { config.messages = :i18n }

      required(:approval).filled(:bool?)
      required(:owner_id).filled(:int?)
      required(:authorized_id).filled(:int?)
    end
  end
end
