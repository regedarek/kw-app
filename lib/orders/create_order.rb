module Orders
  class CreateOrder
    def initialize(service:)
      @service = service
    end

    def create
      if @service.order.present?
        @service.order.update_cost
        @service.order  
      else
        order = Db::Order.new
        order.build_payment(dotpay_id: SecureRandom.hex(13))
        order.reservations << @service if @service.is_a? Db::Reservation
        order.save
        order.update_cost
        ReservationMailer.reserve(@service).deliver_later
        order
      end
    end
  end
end
