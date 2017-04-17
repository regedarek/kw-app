module Mas
  class Edition2017
    def self.sign_up(form:)
      if form.valid?
        sign_up = Db::Mas::SignUp.create(form.params)
        sign_up.create_payment(dotpay_id: SecureRandom.hex(13))
        MasMailer.sign_up(sign_up).deliver_now
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end
  end
end
