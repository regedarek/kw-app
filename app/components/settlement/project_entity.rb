module Settlement
  class ProjectEntity
    def incomings_sum(project)
      project.business_courses.inject(0) do |sum, course|
        sum += course.price.to_i
      end
    end

    def outcomings_sum(project)
      project.contracts.inject(0) do |sum, contract|
        sum += contract.cost
      end
    end
  end
end
