require 'i18n'
require 'dry-validation'

module Management
  ProjectForm = Dry::Validation.Params do
    configure { config.messages_file = 'app/components/management/errors.yml' }
    configure { config.messages = :i18n }

    required(:name).filled(:str?)
    optional(:description).maybe(:str?)
    optional(:needed_knowledge).maybe(:str?)
    optional(:benefits).maybe(:str?)
    optional(:estimated_time).maybe(:str?)
    optional(:know_how).maybe(:str?)
    optional(:attachments).maybe
    optional(:attachments).maybe
    optional(:users_names).maybe
  end
end
