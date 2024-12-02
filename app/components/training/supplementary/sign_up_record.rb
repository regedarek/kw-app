# == Schema Information
#
# Table name: supplementary_sign_ups
#
#  id                                   :integer          not null, primary key
#  code                                 :string           default("3575717639915f7a"), not null
#  email                                :string
#  expired_at                           :datetime
#  name                                 :string
#  paid_email_sent_at                   :datetime
#  question                             :string
#  sent_at                              :datetime
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  admin_id                             :integer
#  course_id                            :integer
#  sent_user_id                         :integer
#  supplementary_course_package_type_id :integer
#  user_id                              :integer
#
# Indexes
#
#  index_supplementary_sign_ups_on_course_id_and_user_id  (course_id,user_id) UNIQUE
#
module Training
  module Supplementary
    class SignUpRecord < ActiveRecord::Base
      self.table_name = 'supplementary_sign_ups'

      has_one :payment, as: :payable, dependent: :destroy, class_name: 'Db::Payment'
      belongs_to :package_type, class_name: 'Training::Supplementary::PackageTypeRecord', foreign_key: :supplementary_course_package_type_id
      belongs_to :user, class_name: 'Db::User', foreign_key: :user_id
      belongs_to :course, class_name: 'Training::Supplementary::CourseRecord', foreign_key: :course_id
      has_many :emails, as: :mailable, class_name: 'EmailCenter::EmailRecord', dependent: :destroy
      has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

      def user_name
        if user
          user.display_name
        else
          name
        end
      end

      def cost
        if course.packages
          return course.price_kw unless package_type

          package_type.cost
        else
          course.price_kw
        end
      end

      def start_date
        return Time.current unless course && course.start_date
        return Time.current unless course.start_date

        course.start_date
      end

      def payment_type
        course.payment_type.to_sym
      end

      def description
        if user
          case payment_type
          when :trainings
            "Szkolenie: #{course.name} - Opłata od #{user.first_name} #{user.last_name} nr legitymacji klubowej #{user.kw_id}"
          when :club_trips
            "Organizacja wyjazdów klubowych: #{course.name} - Opłata od #{user.first_name} #{user.last_name} nr legitymacji klubowej #{user.kw_id}"
          else
            "Wydarzenie klubowe: #{course.name} - Opłata od #{user.first_name} #{user.last_name} nr legitymacji klubowej #{user.kw_id}"
          end
        else
          case payment_type
          when :trainings
            "Szkolenie: #{course.name} - Opłata od #{name}"
          when :club_trips
            "Organizacja wyjazdów klubowych: #{course.name} - Opłata od #{name}"
          else
            "Wydarzenie klubowe: #{course.name} - Opłata od #{name}"
          end
        end
      end
    end
  end
end
