module Orders
  class CreateOrder
    def initialize(service:)
      @service = service
    end

    def create
      if @service.order.present?
        @service.order  
      else
        order = Db::Order.new
        order.build_payment(dotpay_id: SecureRandom.hex(13))
        order.reservations << @service if @service.is_a? Db::Reservation
        order.save
        order
        ReservationMailer.reserve(@service).deliver_later
      end
    end
  end
end
