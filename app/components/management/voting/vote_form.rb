require 'i18n'
require 'dry-validation'

module Management
  module Voting
    VoteForm = Dry::Validation.Params do
      configure { config.messages_file = 'app/components/management/errors.yml' }
      configure { config.messages = :i18n }

      optional(:decision).maybe(:str?)
      optional(:user_ids).maybe
      required(:case_id).filled(:int?)
      required(:user_id).filled(:int?)
      required(:commission).filled(:bool?)
      required(:authorized_id).filled(:int?)
    end
  end
end
