module Admin
  class VersionsController < Admin::BaseController
    def index
      @versions = PaperTrail::Version.order(:created_at)
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