require 'results'
require 'admin/payments_form'

module Admin
  class Payments
    def initialize(allowed_params)
      @allowed_params = allowed_params
    end

    def create
      if form.valid?
        payment = Db::Payment.new(form.params)
        payment.save
        Success.new
      else
        Failure.new(:invalid, form: form)
      end
    end

    def self.destroy(payment_id)
      payment = Db::Payment.find(payment_id)
      if payment.destroy
        Success.new
      else
        Failure.new(:failure)
      end
    end

    def form
      @form ||= Admin::PaymentsForm.new(@allowed_params)
    end
  end
end
