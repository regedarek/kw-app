module Shop
  class Limiter
    def initialize(order)
      @order = order
    end

    def reached?
      true
    end
  end
end
