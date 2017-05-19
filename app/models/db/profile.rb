module Db
  class Profile < ActiveRecord::Base
    RECOMMENDED_BY = %w(google facebook friends festival poster course)
    POSITION = %w(candidate regular honorable_kw honorable_pza management senior instructor canceled)
    SECTIONS = %w(snw sww stj gtw kts)
    ACOMPLISHED_COURSES = %w(basic basic_kw basic_without_second second second_winter cave ski list blank)

    has_one :payment, as: :payable, dependent: :destroy

    validates :email, uniqueness: true

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

    belongs_to :user, foreign_key: :kw_id, primary_key: :kw_id

    def cost
      if acomplished_courses.include?('basic_kw')
        100
      else
        150
      end
    end

    def description
      if acomplished_courses.include?('basic_kw')
        "Składka członkowska za rok #{Date.today.year} od #{first_name} #{last_name}."
      else
        "Wpisowe oraz składka członkowska za rok #{Date.today.year} od #{first_name} #{last_name}."
      end
    end
  end
end
