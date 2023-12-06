class Db::YearlyPrizeRequest < ApplicationRecord
  self.table_name = 'yearly_prize_requests'

  mount_uploaders :attachments, YearlyPrize::AttachmentUploader
  serialize :attachments, JSON

  has_paper_trail

  belongs_to :author, class_name: 'Db::User', foreign_key: :author_id
  belongs_to :yearly_prize_edition, class_name: 'Db::YearlyPrizeEdition', foreign_key: :yearly_prize_edition_id
  belongs_to :yearly_prize_category, class_name: 'Db::YearlyPrizeCategory', foreign_key: :yearly_prize_category_id

  has_many :likes, as: :likeable, class_name: 'Like', dependent: :destroy

  has_many :yearly_prize_request_users, class_name: 'Db::YearlyPrizeRequestUser', foreign_key: :yearly_prize_request_id, dependent: :destroy
  has_many :users, through: :yearly_prize_request_users, class_name: 'Db::User', foreign_key: :user_id

  validates :yearly_prize_edition_id, presence: true
  validates :yearly_prize_category_id, presence: true
  validates :author_id, presence: true

  accepts_nested_attributes_for :users, allow_destroy: true
end
