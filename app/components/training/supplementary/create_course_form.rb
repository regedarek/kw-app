module Training
  module Supplementary
    class CreateCourseForm < Dry::Validation::Schema::Form
      configure do
        option :record
        config.messages = :i18n
        config.messages_file = 'app/components/training/errors.yml'
        config.type_specs = true

        def unique?(attr_name, value)
          record.class.where.not(id: record.id).where(attr_name => value).empty?
        end
      end

      define! do
        required(:name).filled(:str?)
        required(:slug).filled(unique?: :slug)
        required(:place).filled(:str?)
        optional(:organizator_id).maybe
      end
    end
  end
end
