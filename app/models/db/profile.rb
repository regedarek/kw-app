module Db
  class Profile < ActiveRecord::Base
    RECOMMENDED_BY = %w(google facebook friends festival poster course)
    POSITION = %w(candidate regular honorable_kw honorable_pza management senior instructor canceled stj)
    SECTIONS = %w(snw sww stj gtw kts)
    ACOMPLISHED_COURSES = %w(basic_kw basic basic_without_second second second_winter cave ski list blank instructors other_club)

    has_one :payment, as: :payable, dependent: :destroy
    has_many :membership_fees, foreign_key: :kw_id, primary_key: :kw_id, class_name: 'Db::Membership::Fee'
    belongs_to :user, foreign_key: :kw_id, primary_key: :kw_id

    validates :email, uniqueness: true, allow_nil: true

    ransacker :recommended_by do
      Arel.sql("array_to_string(recommended_by, ',')")
    end
    ransacker :position do
      Arel.sql("array_to_string(position, ',')")
    end
    ransacker :sections do
      Arel.sql("array_to_string(sections, ',')")
    end
    ransacker :acomplished_courses do
      Arel.sql("array_to_string(acomplished_courses, ',')")
    end

    def description
      "Wpisowe oraz składka członkowska za rok #{Date.today.year} od #{first_name} #{last_name}."
    end
  end
end
