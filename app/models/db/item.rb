class Db::Item < ActiveRecord::Base
  include Filterable
  enum owner: [:kw, :snw, :sww, :instructors]
  has_many :reservations, through: :reservation_items
  has_many :reservation_items

  scope :display_name, -> (name) { where('display_name ~* ?', name) }
  scope :rentable_id, -> (id) { where(rentable_id: id) }
  scope :owner, -> (type) { where(owner: type) }
  scope :rentable, -> { where(rentable: true) }
end
