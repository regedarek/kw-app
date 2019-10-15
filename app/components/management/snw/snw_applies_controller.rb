module Management
  module Snw
    class SnwAppliesController < ApplicationController
      append_view_path 'app/components'

      def index
        @snw_applies = Management::Snw::SnwApplyRecord.all
        authorize! :manage, Management::Snw::SnwApplyRecord
      end

      def new
        @snw_apply = Management::Snw::SnwApplyRecord.new
        authorize! :create, @snw_apply
      end

      def create
        @snw_apply = Management::Snw::SnwApplyRecord.new(apply_params)
        @snw_apply.kw_id = current_user.kw_id

        authorize! :create, @snw_apply

        if @snw_apply.save
          Management::Snw::Mailer.apply(@snw_apply.id).deliver_later
          redirect_to root_path, notice: 'Utworzono zgłoszenie, sprawdź e-mail!'
        else
          render :new
        end
      end

      def show
        @snw_apply = Management::Snw::SnwApplyRecord.find_by(kw_id: params[:id])
        authorize! :read, @snw_apply
      end

      def edit
        @snw_apply = Management::Snw::SnwApplyRecord.find_by(kw_id: params[:id])
      end

      def update
        @snw_apply = Management::Snw::SnwApplyRecord.find_by(kw_id: params[:id])

        if @snw_apply.update(apply_params)
          redirect_to snw_apply_page_path(@snw_apply.kw_id), notice: 'Zaktualizowano zgłoszenie!'
        else
          render :edit
        end
      end

      private

      def apply_params
        params.require(:snw_apply).permit(:cv, :skills, :courses, :avalanche_date, attachments: [])
      end
    end
  end
end
