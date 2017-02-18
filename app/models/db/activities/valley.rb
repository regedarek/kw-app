module Db
  class Valley < ActiveRecord::Base
    has_many :peaks, dependent: :destroy
    validates :name, presence: true
  end
end
