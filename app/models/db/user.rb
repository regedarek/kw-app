class Db::User < ActiveRecord::Base
  include Filterable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  validates :phone, :kw_id, :first_name, :last_name, presence: true
  validates :kw_id, :email, uniqueness: true

  scope :first_name, -> (name) { where first_name: name }
  scope :last_name, -> (name) { where last_name: name }
  scope :email, -> (email) { where email: email }
  scope :kw_id, -> (id) { where kw_id: id }

  has_one  :profile, foreign_key: :kw_id, primary_key: :kw_id
  has_many :auctions
  has_many :reservations
  has_many :mountain_routes, class_name: 'Db::Activities::MountainRoute'
  has_many :orders
  has_many :membership_fees, foreign_key: :kw_id, primary_key: :kw_id
  has_many :events, foreign_key: :manager_kw_id, primary_key: :kw_id

  def display_name
    "#{first_name} #{last_name}"
  end
end
