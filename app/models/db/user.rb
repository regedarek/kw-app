class Db::User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :kw_id, :first_name, :last_name, presence: true

  has_many :reservations
  has_many :membership_payments, class_name: 'Db::MembershipPayment', foreign_key: :kw_id, primary_key: :kw_id
end
