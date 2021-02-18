module Business
  class SignUpsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def create
      @sign_up = Business::SignUpRecord.new(sign_up_params)

      if @sign_up.save
        @sign_up.create_payment(dotpay_id: SecureRandom.hex(13))
        ::Business::SignUpMailer.sign_up(@sign_up.id).deliver_later
        redirect_to public_course_path(@sign_up.course_id), notice: 'Zapisano'
      else
        redirect_to public_course_path(@sign_up.course_id), alert: 'Problem'
      end
    end

    private

    def sign_up_params
      params.require(:sign_up).permit(:name, :email, :user_id, :course_id, :expired_at)
    end
  end
end
