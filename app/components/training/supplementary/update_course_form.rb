module Training
  module Supplementary
    class UpdateCourseForm < Dry::Validation::Contract
        option :record
        config.messages.load_paths << 'app/components/training/errors.yml'
        config.messages.namespace = :course

        register_macro(:slug?) do
          ! /\A[a-z0-9-]+\z/.match(value).nil?
        end

        register_macro(:unique?) do |macro:|
          ko = macro.args[0]
          record.class.where.not(id: record.id).where(ko => value).empty?
        end

        params do
        required(:name).filled(:string)
        required(:slug).filled(:string, max_size?: 31)
        required(:place).filled(:string)
        optional(:email_remarks).maybe(:string)
        optional(:paid_email).maybe(:string)
        optional(:question).maybe(:bool)
        optional(:send_manually).maybe(:bool)
        required(:payment_type).filled
        end

        rule(:slug).validate(:slug?)
        rule(:slug).validate(unique?: :slug)
      end
  end
end
