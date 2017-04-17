module Admin
  class MembershipFees
    def initialize(allowed_params)
      @allowed_params = allowed_params
    end

    def create
      if form.valid?
        fee = Db::Membership::Fee.new(form.params)
        fee.save
        payment = fee.create_payment(dotpay_id: SecureRandom.hex(13))
        payment.update(cash: true) if payment.present?
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end

    def self.destroy(payment_id)
      fee = Db::Membership::Fee.find(payment_id)
      if fee.destroy
        Success.new
      else
        Failure.new(:failure)
      end
    end

    def form
      @form ||= Admin::MembershipFeesForm.new(@allowed_params)
    end
  end
end
