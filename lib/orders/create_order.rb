module Orders
  class CreateOrder
    def initialize(service:)
      @service = service
    end

    def create
      if @service.order.present?
        @service.order.update_cost if @service.is_a? Db::Reservation
        @service.order  
      else
        order = Db::Order.new
        order.build_payment(dotpay_id: SecureRandom.hex(13))
        if @service.is_a? Db::Reservation
          order.reservations << @service
          order.update_cost
          ReservationMailer.reserve(@service).deliver_later
        end
        if @service.is_a? Db::Strzelecki::SignUp
          order.strzelecki_sign_ups << @service
          if @service.team?
            order.cost = 200
          else
            order.cost = 100
          end
        end
        order.save
        order
      end
    end
  end
end
