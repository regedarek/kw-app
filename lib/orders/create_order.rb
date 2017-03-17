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
        if @service.is_a? Db::MembershipFee
          order.membership_fees << @service
          cost = if @service.reactivation?
                   @service.cost + 50
                 else
                   @service.cost
                 end
          order.cost = cost
        end
        if @service.is_a? Db::Reservation
          order.reservations << @service
          order.update_cost
          ReservationMailer.reserve(@service).deliver_later
        end
        if @service.is_a? Db::Mas::SignUp
          order.mas_sign_ups << @service
          package_cost_1 = case @service.package_type_1
          when 'kw'
            Db::Mas::SignUp::PRICES[:kw]
          when 'standard'
            Db::Mas::SignUp::PRICES[:standard]
          else
            fail 'wrong payment'
          end
          package_cost_2 = case @service.package_type_2
          when 'none'
            0
          when 'kw'
            Db::Mas::SignUp::PRICES[:kw]
          when 'standard'
            Db::Mas::SignUp::PRICES[:standard]
          else
            fail 'wrong payment'
          end
          order.cost = package_cost_1 + package_cost_2
        end
        order.save
        order
      end
    end
  end
end
