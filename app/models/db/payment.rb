module Db
  class Payment < ActiveRecord::Base
    belongs_to :user, class_name: 'Db::User', foreign_key: :kw_id, primary_key: :kw_id
  end
end
