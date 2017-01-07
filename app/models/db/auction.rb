module Db
  class Auction < ActiveRecord::Base
    belongs_to :user
    has_many :auction_products, inverse_of: :auction, dependent: :destroy

    accepts_nested_attributes_for :auction_products,
      reject_if: proc { |attributes| attributes[:name].blank? }, allow_destroy: true
  end
end
