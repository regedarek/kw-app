module Business
  class SignUpsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      @q = Business::SignUpRecord.includes(:course, :list).ransack(params[:q])
      @q.sorts = 'updated_at desc' if @q.sorts.empty?
      @sign_ups = @q.result(distinct: true).page(params[:page])
    end

    def create
      @sign_up = Business::SignUpRecord.new(sign_up_params)

      if @sign_up.course.sign_ups.count >= @sign_up.course.max_seats
        return redirect_to public_course_path(@sign_up.course_id), alert: 'Niestety nie ma już wolnych miejsc'
      end

      if @sign_up.save
        PaperTrail.request(whodunnit: @sign_up.name) do
          @sign_up.course.update(seats: @sign_up.course.seats + 1)
        end

        @sign_up.payments.create(dotpay_id: SecureRandom.hex(13), amount: @sign_up.course.payment_first_cost)
        ::Business::SignUpMailer.sign_up(@sign_up.id).deliver_later
        redirect_to public_course_path(@sign_up.course_id), notice: 'Zapisaliśmy Cię na kurs, teraz sprawdź e-mail i opłać zadatek'
      else
        @course = @sign_up.course
        render 'business/courses/public'
      end
    end

    def edit
      @sign_up = Business::SignUpRecord.find(params[:id])

      authorize! :manage, @sign_up
    end

    def update
      @sign_up = Business::SignUpRecord.find(params[:id])

      authorize! :manage, @sign_up

      if @sign_up.update(sign_up_params)
        redirect_to edit_business_sign_up_path(@sign_up.id), notice: 'Zaktualizowano zapis'
      else
        render :edit
      end
    end

    def send_second
      @sign_up = Business::SignUpRecord.find(params[:id])

      authorize! :manage, @sign_up

      return false if @sign_up.payments.count >= 2

      @sign_up.accept!
      @sign_up.payments.create(dotpay_id: SecureRandom.hex(13), amount: @sign_up.course.payment_second_cost)
      ::Business::SignUpMailer.sign_up_second(@sign_up.id).deliver_later

      redirect_to edit_business_sign_up_path(@sign_up.id), notice: 'Zaakceptowano zaliczkę i wysłano drugi link!'
    end

    def destroy
      sign_up = Business::SignUpRecord.find(params[:id])

      authorize! :destroy, sign_up

      sign_up.destroy
      redirect_to course_path(sign_up.course.id), notice: 'Usunięto'
    end

    private

    def sign_up_params
      params.require(:sign_up).permit(:name, :email, :user_id, :phone, :rodo, :rules, :data, :course_id, :expired_at)
    end
  end
end
