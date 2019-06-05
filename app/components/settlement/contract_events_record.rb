module Settlement
  class ContractEventsRecord < ActiveRecord::Base
    self.table_name = 'contract_events'

    belongs_to :event, class_name: 'Training::Supplementary::CourseRecord', foreign_key: :event_id, inverse_of: :contract_events
    belongs_to :contract, class_name: 'Settlement::ContractRecord', foreign_key: :contract_id, inverse_of: :contract_events
  end
end
