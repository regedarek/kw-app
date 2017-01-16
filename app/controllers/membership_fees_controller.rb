require 'admin/membership_fees'
require 'admin/membership_fees_form'

class MembershipFeesController < Admin::BaseController
  def create
    result = Membership::PayFee.for(user_id: params[:user_id], year: params[:year])
    result.success { redirect_to root_path, notice: 'Dodano' }
    result.invalid { |form:| redirect_to root_path, alert: "Nie dodano: #{form.errors.messages}" }
    result.else_fail!
  end
end
