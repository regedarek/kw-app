module Admin
  class PeaksController < Admin::BaseController
    def create
      @valleys = Db::Valley.order(:name)
      @valley = Db::Valley.new
      @peak = Db::Peak.new(peak_params)

      if @peak.save
        redirect_to admin_valleys_path, notice: 'Utworzono szczyt'
      else
        render 'admin/valleys/index'
      end
    end

    def destroy
      peak = Db::Peak.find(params[:id])
      peak.destroy

      redirect_to admin_valleys_path, notice: 'Usunieto szczyt'
    end

    private

    def peak_params
      params.require(:peak).permit(:name, :valley_id)
    end
  end
end
