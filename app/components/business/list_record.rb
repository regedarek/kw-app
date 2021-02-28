module Business
  class ListRecord < ActiveRecord::Base
    self.table_name = 'business_lists'

    has_paper_trail

    validates :description, :sign_up_id, :birthplace, :birthdate, presence: true
    validates :sign_up_id, uniqueness: { message: 'zostało już przez Ciebie wysłane' }
    validates :course_ids, length: {
      minimum: 1,
      message: 'musisz wybrać przynajmniej jeden',
      if: :alternative_courses_any?
    }
    validates :rules, acceptance: true

    belongs_to :sign_up, class_name: '::Business::SignUpRecord', foreign_key: :sign_up_id

    has_many :list_courses, class_name: 'Business::ListCourseRecord', foreign_key: :list_id
    has_many :courses, through: :list_courses, dependent: :destroy, foreign_key: :course_id

    private

    def alternative_courses_any?
      Business::CourseRecord
        .where('starts_at >= ?', Time.zone.now)
        .where('max_seats > seats')
        .where(
          state: 'ready',
          activity_type: self.sign_up.course.activity_type
        )
        .where.not(id: self.sign_up.course_id)
        .any?
    end
  end
end
