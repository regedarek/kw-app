module Mas
  class Edition2017
    def self.sign_up(form:)
      return Failure.new(:invalid, form: form) if form.invalid?

      sign_up = Db::Mas::SignUp.new(form.params)

      if sign_up.save
        sign_up.create_payment(dotpay_id: SecureRandom.hex(13))
        MasMailer.sign_up(sign_up).deliver_now
        Success.new
      else
        Failure.new(:error, errors: sign_up.errors.full_messages)
      end
    end
  end
end
