module Admin
  class MembershipPaymentsController < Admin::BaseController
    def index
      kw_id = params.fetch(:admin_membership_payments_form, {}).fetch(:kw_id) if params[:admin_membership_payments_form]
      @membership_payments = if kw_id.present?
                    Db::MembershipPayment.where(kw_id: kw_id).order(:kw_id)
                  else
                    Db::MembershipPayment.order(:kw_id)
                  end
    end

    def create
      result = Admin::MembershipPayments.new(payment_params).create
      result.success { redirect_to admin_membership_payments_path, notice: 'Dodano' }
      result.invalid { |form:| redirect_to admin_membership_payments_path, alert: "Nie dodano: #{form.errors.messages}" }
      result.else_fail!
    end

    def destroy
      result = Admin::MembershipPayments.destroy(params[:id])
      result.success { redirect_to admin_membership_payments_path, notice: 'Usunieto' }
      result.failure { redirect_to admin_membership_payments_path, alert: 'Nie usunieto' }
      result.else_fail!
    end

    private

    def payment_params
      params.require(:admin_membership_payments_form).permit(:kw_id, :year)
    end
  end
end
