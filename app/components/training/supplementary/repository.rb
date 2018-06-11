module Training
  module Supplementary
    class Repository
      def fetch_active_courses(category:)
        categories = if category.present?
          category
        else
          Training::Supplementary::CourseRecord.categories.keys
        end
        Training::Supplementary::CourseRecord
          .where(start_date: 1.day.ago..DateTime::Infinity.new)
          .where(category: categories)
          .order(:start_date, :application_date).collect do |record|
          Training::Supplementary::Course.from_record(record)
        end
      end

      def fetch_inactive_courses(category:)
        categories = if category.present?
          category
        else
          Training::Supplementary::CourseRecord.categories.keys
        end
        Training::Supplementary::CourseRecord
          .where(start_date: nil)
          .where(category: categories)
          .order(:application_date).collect do |record|
          Training::Supplementary::Course.from_record(record)
        end
      end

      def create(form_outputs:)
        o_id = form_outputs[:organizator_id]&.first if form_outputs.to_h.include?(:organizator_id)
        record = Training::Supplementary::CourseRecord
          .create!(form_outputs.to_h.merge!(organizator_id: o_id))
        Training::Supplementary::Course.from_record(record)
      end

      def sign_up!(email:, user_id:, course_id:)
        course = Training::Supplementary::CourseRecord.find(course_id)
        return if course.limit > 0 && course.sign_ups.count >= course.limit

        sign_up = Training::Supplementary::SignUpRecord.create!(
          user_id: user_id,
          course_id: course_id,
          email: email
        )
        sign_up
      end
    end
  end
end
