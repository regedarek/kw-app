# == Schema Information
#
# Table name: yearly_prize_requests
#
#  id                       :bigint           not null, primary key
#  accepted                 :boolean          default(FALSE)
#  attachments              :string
#  author_description       :text
#  likes_count              :integer          default(0), not null
#  prize_jury_description   :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  author_id                :integer          not null
#  yearly_prize_category_id :integer          not null
#  yearly_prize_edition_id  :bigint           not null
#
# Indexes
#
#  index_yearly_prize_requests_on_author_id                 (author_id)
#  index_yearly_prize_requests_on_yearly_prize_category_id  (yearly_prize_category_id)
#  index_yearly_prize_requests_on_yearly_prize_edition_id   (yearly_prize_edition_id)
#
# Foreign Keys
#
#  fk_rails_...  (yearly_prize_edition_id => yearly_prize_editions.id)
#
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
