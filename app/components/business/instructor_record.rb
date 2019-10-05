module Business
  class InstructorRecord < ActiveRecord::Base
    self.table_name = 'business_instructors'

    has_many :courses, dependent: :destroy, class_name: '::Business::CourseRecord', foreign_key: :instructor_id

    def profile_name
      if self.kw_id
        Db::Profile.find_by(kw_id: self.kw_id)&.display_name
      else
        self.name
      end
    end

    def as_json
      super.merge(profile_name: profile_name)
    end
  end
end
