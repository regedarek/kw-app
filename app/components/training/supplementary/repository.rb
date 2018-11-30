module Training
  module Supplementary
    class Repository
      def future_sign_ups_of_user(user)
        Training::Supplementary::SignUpRecord
          .includes(:course)
          .where(user_id: user.id)
          .sort_by(&:start_date)
      end

      def find_sign_up(id)
        Training::Supplementary::SignUpRecord.find(id)
      end

      def fetch_active_courses(category: nil, kind: nil)
        categories = if category.present?
          category
        else
          Training::Supplementary::CourseRecord.categories.keys
        end
        kinds = if kind.present?
          kind
        else
          Training::Supplementary::CourseRecord.kinds.keys
        end
        Training::Supplementary::CourseRecord
          .where(start_date: Date.current.beginning_of_day..DateTime::Infinity.new)
          .where(category: categories, kind: kinds)
          .order(:start_date, :application_date).collect do |record|
          Training::Supplementary::Course.from_record(record)
        end
      end

      def fetch_archived_courses(category: nil, kind: nil)
        categories = if category.present?
          category
        else
          Training::Supplementary::CourseRecord.categories.keys
        end
        kinds = if kind.present?
          kind
        else
          Training::Supplementary::CourseRecord.kinds.keys
        end
        Training::Supplementary::CourseRecord
          .where(start_date: 1.year.ago..Date.current.beginning_of_day)
          .where(category: categories, kind: kinds)
          .order(:start_date, :application_date).collect do |record|
          Training::Supplementary::Course.from_record(record)
        end
      end

      def fetch_inactive_courses(category:, kind: nil)
        categories = if category.present?
          category
        else
          Training::Supplementary::CourseRecord.categories.keys
        end
        kinds = if kind.present?
          kind
        else
          Training::Supplementary::CourseRecord.kinds.keys
        end
        Training::Supplementary::CourseRecord
          .where(start_date: nil)
          .where(category: categories, kind: kinds)
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

      def create_package(form_outputs:)
        course = Training::Supplementary::CourseRecord.find(form_outputs[:course_id])

        course.package_types.create!(
          name: form_outputs[:name],
          cost: form_outputs[:cost]
        )
      end

      def sign_up!(name:, email:, user_id:, course_id:)
        course = Training::Supplementary::CourseRecord.find(course_id)

        sign_up = Training::Supplementary::SignUpRecord.create!(
          name: name,
          user_id: user_id,
          course_id: course_id,
          email: email,
          code: SecureRandom.hex(13)
        )
        sign_up.create_payment(dotpay_id: SecureRandom.hex(13))
        sign_up
      end
    end
  end
end
