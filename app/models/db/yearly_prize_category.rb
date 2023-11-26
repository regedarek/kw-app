class Db::YearlyPrizeCategory < ApplicationRecord
  self.table_name = 'yearly_prize_categories'

  belongs_to :yearly_prize_edition, class_name: 'Db::YearlyPrizeEdition', foreign_key: :yearly_prize_edition_id
  has_many :yearly_prize_requests, class_name: 'Db::YearlyPrizeRequest', foreign_key: :yearly_prize_category_id, dependent: :destroy
end
