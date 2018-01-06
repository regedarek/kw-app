module Strzelecki
  class Edition2017
    def self.sign_up(form:)
      if form.valid?
        strzelecki_sign_up = Db::Strzelecki::SignUp.create(form.params)
        Orders::CreateOrder.new(service: strzelecki_sign_up).create
        return Failure.new(:invalid_order) if !strzelecki_sign_up.service.present? || !strzelecki_sign_up.service.order.present?
        StrzeleckiMailer.sign_up(strzelecki_sign_up).deliver_later
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end
  end
end
