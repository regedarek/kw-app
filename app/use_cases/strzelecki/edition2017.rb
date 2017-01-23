module Strzelecki
  class Edition2017
    def self.sign_up(form:)
      if form.valid?
        strzelecki_sign_up = Db::Strzelecki::SignUp.create(form.params)
        Orders::CreateOrder.new(service: strzelecki_sign_up).create
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end
  end
end
