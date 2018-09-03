class Db::User < ActiveRecord::Base
  mount_uploader :avatar, ::Membership::AvatarUploader

  ROLES = %w(reservations admin events courses competitions office tech donations photo_competition)
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  validates :phone, :kw_id, :first_name, :last_name, presence: true
  validates :kw_id, :email, uniqueness: true

  scope :first_name, -> (name) { where first_name: name }
  scope :last_name, -> (name) { where last_name: name }
  scope :email, -> (email) { where email: email }
  scope :kw_id, -> (id) { where kw_id: id }
  scope :hidden, -> { Db::User.where(hide: true) }
  scope :not_hidden, -> { Db::User.where(hide: false) }
  scope :active, -> { Db::User.includes(membership_fees: :payment).where(membership_fees: { year: [(Date.today.year - 1), Date.today.year] }, payments: { state: 'prepaid'} ).or(Db::User.includes(membership_fees: :payment).where(membership_fees: { year: [(Date.today.year - 1), Date.today.year] }, payments: { cash: true} )) }

  has_one  :profile, foreign_key: :kw_id, primary_key: :kw_id
  has_many :reservations
  has_many :membership_fees, foreign_key: :kw_id, primary_key: :kw_id, class_name: 'Db::Membership::Fee'
  has_many :photo_requests, class_name: 'PhotoCompetition::RequestRecord'

  has_many :hearts, dependent: :destroy
  has_many :fav_mountain_routes, through: :hearts

  has_many :mountain_routes, class_name: 'Db::Activities::MountainRoute'
  has_many :colleagues_mountain_routes,
    through: :route_colleagues,
    class_name: 'Db::Activities::MountainRoute'
  has_many :route_colleagues, class_name: 'Db::Activities::RouteColleagues'

  def display_name
    "#{first_name} #{last_name}"
  end

  def rodo_name
    "#{first_name} #{last_name.first}."
  end

  def admin?
    roles.include?('admin')
  end

  def active?
    membership_fees.where(year: [(Date.today.year - 1), Date.today.year]).any? {|f| f&.payment&.paid? }
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = Db::User.find_by(email: data['email'])
    user.update(refresh_token: access_token.try(:credentials).try(:refresh_token)) if user
    user
  end
end
