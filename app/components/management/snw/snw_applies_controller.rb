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
          redirect_to snw_applies_path, notice: 'Utworzono zgłoszenie'
        else
          render :new
        end
      end

      def show
        @snw_apply = Management::Snw::SnwApplyRecord.find(params[:id])
        authorize! :read, @snw_apply
      end

      private

      def apply_params
        params.require(:snw_apply).permit(:cv, :skills, :courses, :avalanche_date, attachments: [])
      end
    end
  end
end
