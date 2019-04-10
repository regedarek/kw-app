module Management
  class ProjectForm < Dry::Validation::Schema::Form
    configure do
      option :record
      config.messages = :i18n
      config.messages_file = 'app/components/training/errors.yml'
      config.type_specs = true
      config.namespace = :project
    end

    define! do
      required(:name).filled(:str?)
    end
  end
end
