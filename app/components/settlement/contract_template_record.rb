# == Schema Information
#
# Table name: contract_templates
#
#  id               :bigint           not null, primary key
#  activity_type    :string
#  area_type        :string
#  description      :text
#  document_type    :string
#  event_type       :string
#  financial_type   :string
#  group_type       :string
#  name             :string
#  payout_type      :string
#  project          :boolean          default(FALSE), not null
#  substantive_type :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  checker_id       :integer
#  project_id       :integer
#
module Settlement
  class ContractTemplateRecord < ActiveRecord::Base
    self.table_name = 'contract_templates'

    has_many :contracts, class_name: 'Settlement::ContractRecord'

    def self.for_select
      Settlement::ContractTemplateRecord.all.map { |template| [template.name, template.id] }
    end
  end
end
