module Training
  module Supplementary
    class CreateSignUpForm < Dry::Validation::Contract
      config.messages.load_paths << 'app/components/training/errors.yml'

      params do
        required(:name).filled(:string)
        required(:email).filled(:string)
        required(:course_id).filled(:string)
        optional(:supplementary_course_package_type_id).maybe(:string)
        optional(:user_id)
        optional(:question).maybe(:string)
      end

      rule(:question, :course_id) do |question, course_id|
        course = Training::Supplementary::CourseRecord.find(course_id)
        if course.question
          !question.blank?
        else
          true
        end
      end
      rule(:supplementary_course_package_type_id) do |supplementary_course_package_type_id|
        if supplementary_course_package_type_id.nil?
          true
        else
          !supplementary_course_package_type_id.blank?
        end
      end
    end
  end
end
