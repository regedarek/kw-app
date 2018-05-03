module Training
  module Supplementary
    class CourseRecord < ActiveRecord::Base
      enum category: [:kw, :snw, :sww, :stj]

      has_many :sign_ups, class_name: 'Training::Supplementary::SignUpRecord', foreign_key: :course_id

      self.table_name = 'supplementary_courses'

      def categories
        Training::Supplementary::CourseRecord.categories.keys.map do |key,value|
          [
            I18n.t("training.supplementary.course.enums.categories.#{key}").humanize,
            key.to_sym
          ]
        end
      end
    end
  end
end
