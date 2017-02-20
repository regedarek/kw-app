require 'admin/membership_fees'
require 'admin/membership_fees_form'

class MembershipFeesController < ApplicationController
  before_action :authenticate_user!

  def index
    @fees = current_user.membership_fees
    @form = Membership::FeeForm.new(kw_id: current_user.kw_id)
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
    params.require(:membership_fee_form).permit(:year, :reactivation)
  end
end
