module Settlement
  class ProjectEntity
    def incomings_sum(project)
      project.business_courses.inject(0) do |sum, course|
        sum += course.price.to_i
      end
    end

    def outcomings_sum(project)
      project.project_items.includes(:accountable).where(accountable_type: 'Settlement::ContractRecord').inject(0) do |sum, item|
        if item.try(:cost)
          sum += item.try(:cost)
        else
          sum += item.try(:accountable).try(:cost)
        end.to_f
      end
    end
  end
end
