# == Schema Information
#
# Table name: yearly_prize_categories
#
#  id                      :bigint           not null, primary key
#  description             :text
#  name                    :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  yearly_prize_edition_id :bigint           not null
#
# Indexes
#
#  index_yearly_prize_categories_on_yearly_prize_edition_id  (yearly_prize_edition_id)
#
# Foreign Keys
#
#  fk_rails_...  (yearly_prize_edition_id => yearly_prize_editions.id)
#
class Db::YearlyPrizeCategory < ApplicationRecord
  self.table_name = 'yearly_prize_categories'

  belongs_to :yearly_prize_edition, class_name: 'Db::YearlyPrizeEdition', foreign_key: :yearly_prize_edition_id
  has_many :yearly_prize_requests, class_name: 'Db::YearlyPrizeRequest', foreign_key: :yearly_prize_category_id, dependent: :destroy
end
