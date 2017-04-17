require 'active_model'

module Availability
  class Form
    include ActiveModel::Model

    attr_accessor :start_date

    def params
      HashWithIndifferentAccess.new(
        start_date: start_date
      )
    end
  end
end
