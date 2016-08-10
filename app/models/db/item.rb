class Db::Item < ActiveRecord::Base
  enum owner: [:kw, :snw, :sww, :instructors]
  has_many :reservations

  scope :rentable, -> { where(rentable: true) }
end
