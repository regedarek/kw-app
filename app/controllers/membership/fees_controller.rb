module Membership
  class FeesController < ApplicationController
    before_action :authenticate_user!, except: [:show]

    def index
      if params[:ids].present?
        kw_ids = params[:ids].split(',').map(&:to_i)
        fees = Db::Membership::Fee.where(kw_id: kw_ids, year: Date.today.year)
        unpaid_fees = fees.select do |fee|
          !fee.payment.paid?
        end
        paid_fees = fees.select do |fee|
          fee.payment.paid?
        end
        other_ids = kw_ids - fees.pluck(:kw_id)
        render json: {
          'opłacone' => paid_fees.pluck(:kw_id),
          'nieopłacone' => unpaid_fees.pluck(:kw_id),
          'brak' => other_ids
          }
      else
        @fees = current_user.membership_fees.order(:year)
        @form = Membership::FeeForm.new(kw_id: current_user.kw_id)
      end
    end

    def show
      fee = Db::Membership::Fee.where(kw_id: params[:id], year: Date.today.year).first
      render plain: fee.present? && fee.payment.paid? ? "#{Date.today.year}: TAK" : "#{Date.today.year}: NIE"
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
      params.require(:membership_fee_form).permit(:year, :plastic)
    end
  end
end
