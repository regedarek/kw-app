require 'i18n'
require 'dry-validation'

module Management
  module Voting
    CaseForm = Dry::Validation.Params do
      configure { config.messages_file = 'app/components/management/errors.yml' }
      configure { config.messages = :i18n }

      required(:name).filled(:str?)
      required(:creator_id).filled(:int?)
      optional(:state).maybe
      optional(:hidden).maybe(:bool?)
      optional(:acceptance_date).maybe(:date?)
      optional(:destrciption).maybe(:str?)
      optional(:number).maybe(:str?)
      optional(:doc_url).maybe(:str?)
      optional(:hide_votes).maybe(:bool?)
      optional(:attachments).maybe
    end
  end
end
