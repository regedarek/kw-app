module Training
  module Supplementary
    class CreateCourseForm < Dry::Validation::Contract
        option :record, default: -> { nil }
        config.messages.load_paths << 'app/components/training/errors.yml'
        config.messages.namespace = :course

        params do
          required(:name).filled(:string)
          required(:place).filled(:string)
          required(:payment_type).filled
          
          # Dates
          optional(:start_date).maybe(:string)
          optional(:end_date).maybe(:string)
          optional(:application_date).maybe(:string)
          optional(:end_application_date).maybe(:string)
          
          # Enum fields
          optional(:category).maybe(:string)
          optional(:kind).maybe(:string)
          optional(:state).maybe(:string)
          optional(:baner_type).maybe(:string)
          
          # Text fields
          optional(:slug).maybe(:string)
          optional(:remarks).maybe(:string)
          optional(:email_remarks).maybe(:string)
          optional(:paid_email).maybe(:string)
          optional(:baner).maybe(:string)
          
          # Integer fields
          optional(:price_kw).maybe(:integer)
          optional(:price_non_kw).maybe(:integer)
          optional(:expired_hours).maybe(:integer)
          optional(:limit).maybe(:integer)
          optional(:organizator_id).maybe(:integer)
          
          # Boolean fields
          optional(:question).maybe(:bool)
          optional(:price).maybe(:bool)
          optional(:one_day).maybe(:bool)
          optional(:active).maybe(:bool)
          optional(:cash).maybe(:bool)
          optional(:reserve_list).maybe(:bool)
          optional(:send_manually).maybe(:bool)
          optional(:open).maybe(:bool)
          optional(:packages).maybe(:bool)
          optional(:last_fee_paid).maybe(:bool)
          
          # Arrays
          optional(:project_ids).maybe(:array)
          optional(:package_types_attributes).maybe(:array)
        end
      end
  end
end
