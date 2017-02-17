module Admin
  class StrzeleckiController < Admin::BaseController
    def index
      @sign_ups = Db::Strzelecki::SignUp.all

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
