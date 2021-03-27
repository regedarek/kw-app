class Db::User < ActiveRecord::Base
  acts_as_messageable
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  mount_uploader :avatar, ::Membership::AvatarUploader

  enum gender: [:male, :female]
  ROLES = %w(training_contracts business_courses library reservations routes admin events courses shop competitions office tech donations photo_competition management secondary_management financial_management marketing projects)
  SNW_GROUPS = %w(mjs instructors management sport authors gear support)
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

  has_many :orders, dependent: :destroy, class_name: '::Shop::OrderRecord', foreign_key: :user_id

  has_many :courses, dependent: :destroy, class_name: '::Business::CourseRecord', foreign_key: :coordinator_id
  has_one  :profile, foreign_key: :kw_id, primary_key: :kw_id
  has_many :reservations
  has_many :membership_fees, foreign_key: :kw_id, primary_key: :kw_id, class_name: 'Db::Membership::Fee'
  has_many :photo_requests, class_name: 'PhotoCompetition::RequestRecord'

  has_many :comments, class_name: 'Messaging::CommentRecord'
  has_many :notifications, class_name: 'NotificationCenter::NotificationRecord', foreign_key: :recipient_id

  has_many :accepted_contracts, class_name: 'Settlement::ContractRecord'
  has_many :created_contracts, class_name: 'Settlement::ContractRecord'

  has_many :contract_users, class_name: 'Settlement::ContractUsersRecord', foreign_key: :user_id
  has_many :contracts, through: :contract_users, foreign_key: :contract_id, dependent: :destroy

  has_many :project_users, class_name: 'Management::ProjectUsersRecord', foreign_key: :user_id
  has_many :projects, through: :project_users, foreign_key: :project_id, dependent: :destroy

  has_many :votes, class_name: 'Management::Voting::VoteRecord', foreign_key: :user_id
  has_many :cases, through: :votes, foreign_key: :case_id, dependent: :destroy

  has_many :hearts, dependent: :destroy
  has_many :fav_mountain_routes, through: :hearts

  has_many :training_user_contracts, class_name: 'Training::Activities::UserContractRecord', foreign_key: :user_id
  has_many :training_contracts, through: :training_user_contracts, source: :contract

  has_many :route_colleagues, class_name: 'Db::Activities::RouteColleagues',
    foreign_key: :colleague_id
  has_many :mountain_routes,
    through: :route_colleagues,
    class_name: 'Db::Activities::MountainRoute'

  has_many :vote_users, class_name: 'Management::Voting::VoteUsersRecord', foreign_key: :user_id
  has_many :member_votes, through: :vote_users, foreign_key: :vote_id, dependent: :destroy, source: :vote

  ransacker :full_name do |parent|
    Arel::Nodes::NamedFunction.new('CONCAT_WS', [
      Arel::Nodes.build_quoted(' '), parent.table[:first_name], parent.table[:last_name]
    ])
  end

  def slug_candidates
    [
      [:first_name, :last_name],
      [:first_name, :last_name, :kw_id],
    ]
  end

  def mailboxer_email(object)
    #Check if an email should be sent for that object
    #if true
    return email
    #if false
    #return nil
  end

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
    Membership::Activement.new(user: self).active?
  end

  def active_and_regular?
    Membership::Activement.new(user: self).active_and_regular?
  end

  def strava_token
    return nil unless strava_access_token && strava_refresh_token
    return strava_access_token if Time.current < strava_expires_at

    client = ::Strava::OAuth::Client.new(
      client_id: Rails.application.secrets.strava_client,
      client_secret: Rails.application.secrets.strava_secret
    )
    response = client.oauth_token(
      refresh_token: self.strava_refresh_token,
      grant_type: 'refresh_token'
    )
    update(
      strava_access_token: response.access_token,
      strava_refresh_token: response.refresh_token,
      strava_expires_at: response.expires_at
    )
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = Db::User.find_by(email: data['email'])
    user.update(refresh_token: access_token.try(:credentials).try(:refresh_token)) if user
    user
  end

  def send_devise_notification(notification, *args)
    if self.profile
      my_locale = self.profile.locale
    else
      my_locale = I18n.default_locale
    end

    I18n.with_locale(my_locale) { super(notification, *args) }
  end
end
