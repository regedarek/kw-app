module Business
  class SignUpRecord < ActiveRecord::Base
    self.table_name = 'business_sign_ups'

    has_one :payment, as: :payable, dependent: :destroy, class_name: 'Db::Payment'
    belongs_to :user, class_name: 'Db::User', foreign_key: :user_id
    belongs_to :course, class_name: 'Business::CourseRecord', foreign_key: :course_id
    has_many :emails, as: :mailable, class_name: 'EmailCenter::EmailRecord', dependent: :destroy
    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    def cost
      course.price
    end

    def payment_type
      course.payment_type
    end

    def start_date
      return Time.current unless course && course.start_date
      return Time.current unless course.start_date

      course.start_date
    end

    def description
      "Kurs Szkoły Alpinizmu: #{course.name} - Opłata od #{name}"
    end
  end
end
