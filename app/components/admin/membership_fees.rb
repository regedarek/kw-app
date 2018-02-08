module Admin
  class MembershipFees
    def initialize(creator_id:, allowed_params:)
      @allowed_params = allowed_params
      @creator_id = creator_id
    end

    def create
      if form.valid?
        fee = Db::Membership::Fee.new(form.params)
        fee.creator_id = @creator_id
        fee.save
        payment = fee.create_payment(dotpay_id: SecureRandom.hex(13))
        payment.update(cash: true, state: 'prepaid') if payment.present?
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
