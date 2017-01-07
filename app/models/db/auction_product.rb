module Db
  class AuctionProduct < ActiveRecord::Base
    belongs_to :auction, inverse_of: :auction_products
  end
end
