class Db::Reservation < ActiveRecord::Base
  include Workflow
  belongs_to :user
  belongs_to :item

  scope :not_archived, -> { where.not(state: :archived) }
  scope :archived, -> { where(state: :archived) }
  scope :expire_tomorrow, -> { where(end_date: 1.day.ago.to_date) }
  
  delegate :kw_id, to: :user

  workflow_column :state
  workflow do
    state :availible do
      event :reserve, :transitions_to => :reserved
      event :archive, :transitions_to => :archived
    end
    state :reserved do
      event :give, :transitions_to => :holding
    end
    state :holding do
      event :give_back, :transitions_to => :availible
    end
    state :archived
  end
end
