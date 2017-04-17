require 'admin/membership_fees'
require 'admin/membership_fees_form'

module Admin
  class MembershipFeesController < Admin::BaseController
    def index
      kw_id = params.fetch(:admin_membership_fees_form, {}).fetch(:kw_id) if params[:admin_membership_fees_form]
      @membership_fees = if kw_id.present?
                    Db::Membership::Fee.where(kw_id: kw_id).order(created_at: :desc)
                  else
                    Db::Membership::Fee.order(created_at: :desc)
                  end.page(params[:page])

      respond_to do |format|
        format.html
        format.xlsx do
          disposition = "attachment; filename='skladki_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.xlsx'"
          response.headers['Content-Disposition'] = disposition
        end
      end
    end

    def create
      result = Admin::MembershipFees.new(payment_params).create
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
