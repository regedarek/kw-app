class Db::Reservation < ActiveRecord::Base
  include Workflow
  belongs_to :user
  has_many :reservation_items
  has_many :items, through: :reservation_items
  has_one :service, as: :serviceable
  has_one :order, through: :service

  default_scope { order('start_date') } 
  scope :not_prepaid, -> { joins(order: :payment).where.not(payments: { state: 'prepaid' }) }
  scope :not_archived, -> { where.not(state: :archived) }
  scope :archived, -> { where(state: :archived) }
  scope :expire_tomorrow, -> { where(end_date: 1.day.ago.to_date) }
  scope :reserved, -> { where(state: :reserved) }
  
  delegate :kw_id, to: :user

  workflow_column :state
  workflow do
    state :reserved do
      event :archive, :transitions_to => :archived
    end
    state :archived
  end
end
