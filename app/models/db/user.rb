class Db::User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :kw_id, :first_name, :last_name, presence: true

  has_many :reservations
  has_many :orders
end
