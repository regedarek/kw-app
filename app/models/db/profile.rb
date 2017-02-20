module Db
  class Profile < ActiveRecord::Base
    RECOMMENDED_BY = %w(google facebook friends festival poster)
    SECTIONS = %w(snw sww stj gtw kts)
    ACOMPLISHED_COURSES = %w(basic second second_winter cave ski list)

    validates :kw_id, uniqueness: true
    belongs_to :user, foreign_key: :kw_id, primary_key: :kw_id
  end
end
