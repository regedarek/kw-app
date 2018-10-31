module Training
  module Supplementary
    class CreateSignUpForm < Dry::Validation::Schema::Form
      configure do
        config.messages = :i18n
        config.messages_file = 'app/components/training/errors.yml'
        config.type_specs = true
      end

      define! do
        required(:name).filled(:str?)
        required(:email).filled(:str?)
        validate(package_required: [:supplementary_course_package_type_id]) do |supplementary_course_package_type_id|
          if supplementary_course_package_type_id.nil?
            true
          else
            !supplementary_course_package_type_id.blank?
          end
        end
        optional(:supplementary_course_package_type_id).maybe(:str?)
        optional(:user_id)
      end
    end
  end
end
