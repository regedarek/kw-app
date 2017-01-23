module Db
  module Strzelecki
    class SignUp < ActiveRecord::Base
      self.table_name = "strzelecki_sign_ups"

      has_one :service, as: :serviceable
      has_one :order, through: :service
    end
  end
end
