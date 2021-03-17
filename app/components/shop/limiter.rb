module Shop
  class Limiter
    def initialize(order)
      @order = order
    end

    def reached?
      @order.order_items.any? do |order_item|
        sold_item_kinds = order_item.item_kind.order_items.inject(0) do |sum,oi|
          if oi.order.payment.paid?
            sum + 1
          else
            sum
          end
        end

        order_item.item_kind.quantity <= sold_item_kinds
      end
    end
  end
end
