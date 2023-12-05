module YearlyPrize
  module Editions
    class RequestsController < ApplicationController
      append_view_path 'app/components'

      before_action :set_edition

      def index
        return redirect_to root_url, alert: 'Musisz być zalogowany i mieć dostęp do zgloszen!' unless user_signed_in? && (current_user.roles.include?('management') || current_user.roles.include?('secondary_management') || current_user.roles.include?('office'))

        @requests = @edition.yearly_prize_requests.includes(:author, :yearly_prize_category).order(created_at: :desc)
      end

      def show
        @request = @edition.yearly_prize_requests.find(params[:request_id])
      end

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
        params.require(:request).permit(:name, :yearly_prize_edition_id, :author_description, :prize_jury_description, :yearly_prize_category_id, user_ids: [], attachments: [])
      end
    end
  end
end
