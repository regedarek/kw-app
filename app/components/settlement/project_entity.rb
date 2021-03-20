module Settlement
  class ProjectEntity
    def incomings_sum(project)
      project.business_courses.inject(0) do |sum, course|
        sum += course.price.to_i
      end
    end

    def outcomings_sum(project)
      project.project_items.includes(:accountable).where(accountable_type: 'Settlement::ContractRecord').inject(0) do |sum, item|
        if item
          if item.cost
            sum += item.cost
          else
            sum += item.accountable.cost
          end
        else
          sum += 0
        end
      end
    end
  end
end
