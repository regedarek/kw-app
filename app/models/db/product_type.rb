module Db
  class ProductType < ActiveRecord::Base
    has_many :field, class_name: 'ProductField'
  end
end
