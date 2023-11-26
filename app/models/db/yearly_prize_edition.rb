class Db::YearlyPrizeEdition < ApplicationRecord
  self.table_name = 'yearly_prize_editions'

  has_many :yearly_prize_categories, class_name: 'Db::YearlyPrizeCategory', foreign_key: :yearly_prize_edition_id, dependent: :destroy
  has_many :yearly_prize_requests, class_name: 'Db::YearlyPrizeRequest', foreign_key: :yearly_prize_edition_id, dependent: :destroy

  validates :name, presence: true
  validates :year, presence: true, uniqueness: true

  def self.create_with_categories(year)
    edition = Db::YearlyPrizeEdition.create(name: "Klubowa Ósemka", year: year)
    edition.yearly_prize_categories.create(name: 'Ósemka STJ')
    edition.yearly_prize_categories.create(name: 'Ósemka SNW')
    edition.yearly_prize_categories.create(name: 'Ósemka SWW')
    edition.yearly_prize_categories.create(name: 'Ósemka od Klubowiczów')
  end
end
