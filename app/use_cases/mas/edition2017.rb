module Mas
  class Edition2017
    def self.sign_up(form:)
      if form.valid?
        sign_up = Db::Mas::SignUp.create(form.params)
        Orders::CreateOrder.new(service: sign_up).create
        return Failure.new(:invalid_order) if !sign_up.service.present? || !sign_up.service.order.present?
        MasMailer.sign_up(sign_up).deliver_later
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end
  end
end
