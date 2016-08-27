require 'results'

module Admin
  class MembershipPayments
    def initialize(allowed_params)
      @allowed_params = allowed_params
    end

    def create
      if form.valid?
        payment = Db::MembershipPayment.new(form.params)
        payment.save
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end

    def self.destroy(payment_id)
      payment = Db::MembershipPayment.find(payment_id)
      if payment.destroy
        Success.new
      else
        Failure.new(:failure)
      end
    end

    def form
      @form ||= Admin::MembershipPaymentsForm.new(@allowed_params)
    end
  end
end
