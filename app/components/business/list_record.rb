module Business
  class ListRecord < ActiveRecord::Base
    self.table_name = 'business_lists'

    has_paper_trail

    validates :description, :sign_up_id, :birthplace, :birthdate, presence: true
    validates :sign_up_id, uniqueness: { message: 'zostało już przez Ciebie wysłane' }
    validates :course_ids, :length => { :minimum => 1, message: 'musisz wybrać przynajmniej jeden'}
    validates :rules, acceptance: true

    belongs_to :sign_up, class_name: '::Business::SignUpRecord', foreign_key: :sign_up_id

    has_many :list_courses, class_name: 'Business::ListCourseRecord', foreign_key: :list_id
    has_many :courses, through: :list_courses, dependent: :destroy, foreign_key: :course_id
  end
end
