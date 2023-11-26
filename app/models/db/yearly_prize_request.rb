class Db::YearlyPrizeRequest < ApplicationRecord
  self.table_name = 'yearly_prize_requests'

  belongs_to :user, class_name: 'Db::User', foreign_key: :user_id
  belongs_to :author, class_name: 'Db::User', foreign_key: :author_id
  belongs_to :yearly_prize_edition, class_name: 'Db::YearlyPrizeEdition', foreign_key: :yearly_prize_edition_id
  belongs_to :yearly_prize_category, class_name: 'Db::YearlyPrizeCategory', foreign_key: :yearly_prize_category_id

  has_many :likes, as: :likeable, class_name: 'Like', dependent: :destroy
end
