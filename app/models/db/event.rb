module Db
  class Event < ActiveRecord::Base
    belongs_to :user, foreign_key: :manager_kw_id, primary_key: :manager_kw_id
  end
end
