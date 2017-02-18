module Db
  class Profile < ActiveRecord::Base
    belongs_to :user, foreign_key: :kw_id, primary_key: :kw_id
  end
end
