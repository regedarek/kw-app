module Db
  class Profile < ActiveRecord::Base
    RECOMMENDED_BY = %w(google facebook friends festival poster)
    POSITION = %w(candidate regular honorable_kw honorable_pza management senior instructor canceled)
    SECTIONS = %w(snw sww stj gtw kts)
    ACOMPLISHED_COURSES = %w(basic second second_winter cave ski list)

    validates :email, uniqueness: true

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
  end
end
