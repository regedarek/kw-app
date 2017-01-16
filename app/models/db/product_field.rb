module Db
  class ProductField < ActiveRecord::Base
    belongs_to :product_type
  end
end
