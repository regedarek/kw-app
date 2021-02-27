module Business
  class ListsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def new
      @sign_up = Business::SignUpRecord.find(params[:id])
      @list = Business::ListRecord.new

      render layout: 'public'
    end

    def ask
      @sign_up = Business::SignUpRecord.find(params[:id])
      ::Business::SignUpMailer.list(@sign_up.id).deliver_later
    end

    def create
      @sign_up = Business::SignUpRecord.find(params[:id])
      @list = Business::ListRecord.new(list_params)

      if @list.save
        redirect_to public_course_path(@list.sign_up.course_id), notice: 'Wysłaliśmy twoje zapotrzebowanie na sprzęt. Po zatwierdzeniu twojego zapisu otrzymasz e-mail od koordynatora.'
      else
        render :new
      end
    end

    private

    def list_params
      params.require(:list).permit(:description, :sign_up_id)
    end
  end
end
