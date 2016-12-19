class Db::Reservation < ActiveRecord::Base
  include Workflow
  belongs_to :user
  has_many :reservation_items
  has_many :items, through: :reservation_items
  has_one :service, as: :serviceable
  has_one :order, through: :service

  default_scope { order('start_date') } 
  scope :not_prepaid, -> { joins(order: :payment).where.not(payments: { state: 'prepaid' }) }
  scope :not_cash, -> { joins(order: :payment).where(payments: { cash: false }) }
  scope :cash_prepaid, -> { joins(order: :payment).where(payments: { cash: true }) }
  scope :not_archived, -> { where.not(state: :archived) }
  scope :archived, -> { where(state: :archived) }
  scope :expire_tomorrow, -> { where(end_date: 1.day.ago.to_date) }
  scope :reserved, -> { where(state: :reserved) }
  scope :holding, -> { where(state: :holding) }
  
  delegate :kw_id, to: :user

  workflow_column :state
  workflow do
    state :reserved do
      event :give, :transitions_to => :holding
      event :archive, :transitions_to => :archived
    end
    state :holding do
      event :archive, :transitions_to => :archived
    end
    state :archived
  end

  def self.to_csv
    attributes = %w{order_id user_name items_display cost when state}

    CSV.generate(headers: true) do |csv|
      csv << ['Nr zamówienia', 'Użytkownik', 'Przedmioty', 'Koszt', 'Kiedy?', 'Status']

      all.each do |reservation|
        csv << attributes.map{ |attr| reservation.send(attr) }
      end
    end
  end

  def order_id
    order.id
  end

  def user_name
    [user.first_name, user.last_name].join(' ')
  end

  def items_display
    items.map{ |i| "#{i.display_name} #{i.rentable_id}" }
  end

  def cost
    order.cost
  end

  def when
    [start_date.strftime("%d"), end_date.strftime("%d/%m/%Y")].join('-')
  end
end
