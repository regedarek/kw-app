module Settlement
  class ProjectEntity
    def incomings_sum(project)
      project.project_items.includes(:accountable).where(accountable_type: ['Business::CourseRecord', 'Settlement::IncomeRecord', 'Training::Supplementary::CourseRecord']).inject(0) do |sum, item|
        sum += item.accountable.try(:cost).to_f if item.accountable_type == 'Settlement::IncomeRecord'
        sum += item.try(:accountable).try(:price).to_f if item.accountable_type == 'Business::CourseRecord'
        sum += item.try(:accountable).try(:price_kw).to_f if item.accountable_type == 'Training::Supplementary::CourseRecord'
        sum
      end
    end

    def outcomings_sum(project)
      project.project_items.includes(:accountable).where(accountable_type: 'Settlement::ContractRecord').inject(0) do |sum, item|
        if item.try(:cost)
          sum += item.try(:cost).to_f
        else
          sum += item.try(:accountable).try(:cost).to_f
        end
      end
    end
  end
end
