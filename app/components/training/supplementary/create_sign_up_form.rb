module Training
  module Supplementary
    class CreateSignUpForm < Dry::Validation::Schema
      configure do
        config.messages = :i18n
        config.messages_file = 'app/components/training/errors.yml'
        config.type_specs = true
      end

      define! do
        required(:name).filled(:str?)
        required(:email).filled(:str?)
        required(:course_id).filled(:str?)
        validate(question_required: [:question, :course_id]) do |question, course_id|
          course = Training::Supplementary::CourseRecord.find(course_id)
          if course.question
            !question.blank?
          else
            true
          end
        end
        validate(package_required: [:supplementary_course_package_type_id]) do |supplementary_course_package_type_id|
          if supplementary_course_package_type_id.nil?
            true
          else
            !supplementary_course_package_type_id.blank?
          end
        end
        optional(:supplementary_course_package_type_id).maybe(:str?)
        optional(:user_id)
        optional(:question).maybe(:str?)
      end
    end
  end
end
