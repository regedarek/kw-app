class Db::Item < ActiveRecord::Base
  enum owner: [:kw, :snw, :sww, :instructors]
  has_many :reservations, through: :reservation_checkouts
  has_many :reservation_checkouts

  scope :rentable, -> { where(rentable: true) }
end
