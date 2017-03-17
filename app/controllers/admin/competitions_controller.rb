module Admin
  class CompetitionsController < Admin::BaseController
    def index
      @sign_ups = Db::Mas::SignUp.order(:created_at)

      respond_to do |format|
        format.html
        format.xlsx do
          disposition = "attachment; filename='mas_#{Time.now.strftime("%Y-%m-%d-%H%M%S")}.xlsx'"
          response.headers['Content-Disposition'] = disposition
        end
      end
    end
  end
end
