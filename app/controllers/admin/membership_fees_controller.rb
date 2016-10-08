module Admin
  class MembershipFeesController < Admin::BaseController
    def index
      kw_id = params.fetch(:admin_membership_fees_form, {}).fetch(:kw_id) if params[:admin_membership_fees_form]
      @membership_fees = if kw_id.present?
                    Db::MembershipFee.where(kw_id: kw_id).order(:kw_id)
                  else
                    Db::MembershipFee.order(:kw_id)
                  end.page(params[:page])
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
