module Admin
  class ProfilesController < Admin::BaseController
    def index
      @profiles = Db::Profile.page(params[:page])

      respond_to do |format|
        format.html
        format.xlsx do
          disposition = "attachment; filename='strzelecki_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.xlsx'"
          response.headers['Content-Disposition'] = disposition
        end
      end
    end
  end
end
