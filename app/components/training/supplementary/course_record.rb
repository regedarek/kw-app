module Training
  module Supplementary
    class CourseRecord < ActiveRecord::Base
      mount_uploader :baner, Training::Supplementary::BanerUploader
      enum category: [:kw, :snw, :sww, :stj]

      has_many :sign_ups, class_name: 'Training::Supplementary::SignUpRecord', foreign_key: :course_id
      has_many :package_types,
        class_name: 'Training::Supplementary::PackageTypeRecord',
        dependent: :destroy,
        foreign_key: :supplementary_course_record_id

      self.table_name = 'supplementary_courses'

      def organizer
        ::Db::User.find(organizator_id)
      end

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
