module Business
  class CourseTypesController < ApplicationController
    append_view_path 'app/components'

    def index
      @course_types = ::Business::CourseTypeRecord.all
    end
  end
end
