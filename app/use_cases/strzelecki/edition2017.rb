module Strzelecki
  class Edition2017
    def self.sign_up(form:)
      if form.valid?
        strzelecki_sign_up = Db::Strzelecki::SignUp.create(form.params)
        Orders::CreateOrder.new(service: strzelecki_sign_up).create
        StrzeleckiMailer.sign_up(strzelecki_sign_up).deliver
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end
  end
end
