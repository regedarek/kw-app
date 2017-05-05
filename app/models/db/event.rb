module Db
  class Event < ActiveRecord::Base
    belongs_to :user, foreign_key: :manager_kw_id, primary_key: :kw_id

    validates :name, uniqueness: true
  end
end
