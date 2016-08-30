module Db
  class Service < ActiveRecord::Base
    belongs_to :order
    belongs_to :serviceable, polymorphic: true
  end
end
