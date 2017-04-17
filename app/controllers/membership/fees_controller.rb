module Membership
  class FeesController < ApplicationController
    before_action :authenticate_user!

    def index
      @fees = current_user.membership_fees
      @form = Membership::FeeForm.new(kw_id: current_user.kw_id)
    end

    def show
      fee = Db::Membership::Fee.where(kw_id: params[:id], year: Date.today.year).first
      render text: { fee.present? && fee.payment.paid? ? "#{Date.today.year}: TAK" : "#{Date.today.year}: NIE" }
    end

    def create
      @fees = current_user.membership_fees
      @form = Membership::FeeForm.new(fee_params.merge(kw_id: current_user.kw_id))

      result = Membership::PayFee.pay(kw_id: current_user.kw_id, form: @form)
      result.success { |payment:| redirect_to charge_payment_path(payment.id) }
      result.invalid { |form:| render :index, form: form }
      result.wrong_payment { redirect_to membership_fees_path, alert: 'Skontaktuj sie z administratorem.' }
      result.else_fail!
    end

    private

    def fee_params
      params.require(:membership_fee_form).permit(:year)
    end
  end
end
