module Payments
  class Notification
    def initialize(params)
      @params = params
    end

    def completed?
      true
    end
  end
end
