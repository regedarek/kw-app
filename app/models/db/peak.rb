module Db
  class Peak < ActiveRecord::Base
    belongs_to :valley
    has_many :routes
    validates :name, :valley_id, presence: true
    validates :name, uniqueness: { scope: :valley_id }
  end
end
