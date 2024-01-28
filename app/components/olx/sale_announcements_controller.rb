module Olx
  class SaleAnnouncementsController < ApplicationController
    append_view_path 'app/components'

    def index
      @sale_announcements = ::Olx::SaleAnnouncementRecord.includes([:user]).where(archived: false).or(
        ::Olx::SaleAnnouncementRecord.includes([:user]).where(user: current_user, archived: true)
      ).distinct.order(updated_at: :desc)
    end

    def show
      @sale_announcement = Olx::SaleAnnouncementRecord.find(params[:id])
    end

    def new
      @sale_announcement = Olx::SaleAnnouncementRecord.new
    end

    def create
      @sale_announcement = Olx::SaleAnnouncementRecord.new(announcement_params)
      @sale_announcement.user = current_user

      if @sale_announcement.save
        redirect_to olx_sale_announcements_path, notice: "Dodano"
      else
        render :new
      end
    end

    def edit
      @sale_announcement = Olx::SaleAnnouncementRecord.find(params[:id])
    end

    def update
      @sale_announcement = Olx::SaleAnnouncementRecord.find(params[:id])

      if @sale_announcement.update(announcement_params)
        redirect_to olx_sale_announcement_path(@sale_announcement), notice: "Zapisano"
      else
        render :edit
      end
    end

    def destroy
      @sale_announcement = Olx::SaleAnnouncementRecord.find(params[:id])
      @sale_announcement.destroy

      redirect_to sale_announcements_path
    end

    private

    def announcement_params
      params.require(:sale_announcement).permit(:name, :description, :archived, :price, photos_attributes: [:file, :_destroy, :id])
    end
  end
end
