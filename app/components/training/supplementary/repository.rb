module Training
  module Supplementary
    class Repository
      def future_courses_of_user(user)
        Training::Supplementary::CourseRecord
          .joins(:sign_ups)
          .where(supplementary_sign_ups: { user_id: user.id }, start_date: Date.current.beginning_of_day..DateTime::Infinity.new)
          .order(start_date: :asc)
          .take(5)
      end

      def future_sign_ups_of_user(user)
        Training::Supplementary::SignUpRecord
          .includes(:course)
          .where(user_id: user.id)
          .sort_by(&:start_date)
          .take(5)
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
          .where(category: categories, kind: kinds, state: :published)
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
          .where(category: categories, kind: kinds)
          .order(created_at: :desc, start_date: :desc, application_date: :desc).collect do |record|
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
        record.update(packages: true) if record.package_types.any?

        Training::Supplementary::Course.from_record(record)
      end

      def create_package(form_outputs:)
        course = Training::Supplementary::CourseRecord.find(form_outputs[:course_id])

        course.package_types.create!(
          name: form_outputs[:name],
          cost: form_outputs[:cost]
        )
      end

      def sign_up!(name:, email:, user_id:, course_id:, question:)
        course = Training::Supplementary::CourseRecord.find(course_id)
        expired_at = unless course.expired_hours.zero?
          Time.zone.now + course.expired_hours.hours
        end

        sign_up = Training::Supplementary::SignUpRecord.create!(
          name: name,
          user_id: user_id,
          course_id: course_id,
          email: email,
          code: SecureRandom.hex(13),
          expired_at: expired_at,
          question: question
        )
        sign_up.create_payment(dotpay_id: SecureRandom.hex(13))
        sign_up
      end

      def expired_sign_ups
        Training::Supplementary::SignUpRecord
          .joins(:payment)
          .where.not(sent_at: nil, expired_at: nil)
          .where('expired_at < ?', Time.zone.now)
          .where(payments: { state: 'unpaid' })
      end
    end
  end
end
