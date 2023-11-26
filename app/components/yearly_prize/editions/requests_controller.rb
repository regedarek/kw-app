module YearlyPrize
  module Editions
    class RequestsController < ApplicationController
      append_view_path 'app/components'

      before_action :set_edition

      def new
        return redirect_to root_url, alert: 'Musisz być zalogowany!' unless user_signed_in?

        @request = @edition.yearly_prize_requests.new
      end

      def create
        return redirect_to root_url, alert: 'Musisz być zalogowany!' unless user_signed_in?

        @request = @edition.yearly_prize_requests.new(request_params)
        @request.author = current_user

        if @request.save
          redirect_to root_path, notice: 'Nominacja została zgłoszona!'
        else
          render :new
        end
      end

      private

      def set_edition
        @edition = Db::YearlyPrizeEdition.find_by!(year: params[:year])
      end

      def request_params
        params.require(:request).permit(:name, :yearly_prize_edition_id, :yearly_prize_category_id, user_ids: [], attachments: [])
      end
    end
  end
end
