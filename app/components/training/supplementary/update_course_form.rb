module Training
  module Supplementary
    class UpdateCourseForm < Dry::Validation::Schema
      configure do
        option :record
        config.messages = :i18n
        config.messages_file = 'app/components/training/errors.yml'
        config.type_specs = true
        config.namespace = :course

        def unique?(attr_name, value)
          record.class.where.not(id: record.id).where(attr_name => value).empty?
        end

        def slug?(value)
          ! /\A[a-z0-9-]+\z/.match(value).nil?
        end
      end

      define! do
        required(:name).filled(:str?)
        required(:slug).filled(:slug?, unique?:(:slug), max_size?: 31)
        required(:place).filled(:str?)
        optional(:email_remarks).maybe(:str?)
        required(:payment_type).filled
      end
    end
  end
end
