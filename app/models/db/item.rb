class Db::Item < ActiveRecord::Base
  enum owner: [:kw, :snw, :sww, :instructors]
  has_many :reservations, through: :reservation_items
  has_many :reservation_items

  scope :rentable, -> { where(rentable: true) }
end
