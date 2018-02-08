require 'admin/membership_fees'
require 'admin/membership_fees_form'

module Admin
  class MembershipFeesController < Admin::BaseController
    def index
      prepaid_fees = Db::Membership::Fee.includes(:payment).order(created_at: :desc)
      @q = prepaid_fees.ransack(params[:q])
      @q.sorts = 'created_at desc' if @q.sorts.empty?
      @membership_fees = @q.result.includes(:user, :payment).page(params[:page])

      respond_to do |format|
        format.html
        format.xlsx do
          disposition = "attachment; filename='skladki_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.xlsx'"
          response.headers['Content-Disposition'] = disposition
        end
      end
    end

    def create
      result = Admin::MembershipFees.new(creator_id: current_user.id, allowed_params: payment_params).create
      result.success { redirect_to admin_membership_fees_path, notice: 'Dodano' }
      result.invalid { |form:| redirect_to admin_membership_fees_path, alert: "Nie dodano: #{form.errors.messages}" }
      result.else_fail!
    end

    def destroy
      result = Admin::MembershipFees.destroy(params[:id])
      result.success { redirect_to admin_membership_fees_path, notice: 'Usunieto' }
      result.failure { redirect_to admin_membership_fees_path, alert: 'Nie usunieto' }
      result.else_fail!
    end

    private

    def payment_params
      params.require(:admin_membership_fees_form).permit(:kw_id, :year)
    end
  end
end
