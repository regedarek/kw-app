module Admin
  class VersionsController < Admin::BaseController
    def index
      @versions = PaperTrail::Version.includes(:item).order(created_at: :desc).page(params[:page]).per(20)
    end

    def revert
      @version = PaperTrail::Version.find(params[:id])
      if @version.reify
        @version.reify.save!
      else
        @version.item.destroy
      end
      redirect_to :back, :notice => "Undid #{@version.event}"
    end
  end
end
