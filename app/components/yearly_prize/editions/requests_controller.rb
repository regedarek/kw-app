module YearlyPrize
  module Editions
    class RequestsController < ApplicationController
      append_view_path 'app/components'

      before_action :set_edition

      def index
        if user_signed_in?
          @requests = @edition.yearly_prize_requests.includes(:author, :yearly_prize_category).order(likes_count: :desc, created_at: :desc)
        else
          return redirect_to root_url, alert: 'Musisz być zalogowany!'
        end
      end

      def show
        @request = @edition.yearly_prize_requests.find(params[:request_id])
      end

      def new
        return redirect_to root_url, alert: 'Musisz być zalogowany!' unless user_signed_in?

        @request = @edition.yearly_prize_requests.new
      end

      def edit
        return redirect_to root_url, alert: 'Musisz być zalogowany!' unless user_signed_in? && (current_user.roles.include?('management') || current_user.roles.include?('secondary_management') || current_user.roles.include?('office'))

        @request = @edition.yearly_prize_requests.find(params[:request_id])
      end

      def update
        return redirect_to root_url, alert: 'Musisz być zalogowany!' unless user_signed_in? && (current_user.roles.include?('management') || current_user.roles.include?('secondary_management') || current_user.roles.include?('office'))

        @request = @edition.yearly_prize_requests.find(params[:request_id])

        if @request.update(request_params)
          redirect_to yearly_prize_edition_requests_path(@edition.year), notice: 'Nominacja została zaktualizowana!'
        else
          render :edit
        end
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
        params.require(:request).permit(:name, :yearly_prize_edition_id, :author_description, :prize_jury_description, :yearly_prize_category_id, :accepted, user_ids: [], attachments: [])
      end
    end
  end
end
