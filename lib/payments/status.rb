module Payments
  class Status
    def initialize(notification:)
      @notification = notification
    end

    def process
      if @notification.completed?
        'OK'
      end
    end
  end
end
