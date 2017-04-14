module Admin
  class MembershipFees
    def initialize(allowed_params)
      @allowed_params = allowed_params
    end

    def create
      if form.valid?
        fee = Db::MembershipFee.new(form.params)
        fee.save
        order = Orders::CreateOrder.new(service: fee).create
        order.payment.update(cash: true) if order.payment.present?
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end

    def self.destroy(payment_id)
      fee = Db::MembershipFee.find(payment_id)
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
