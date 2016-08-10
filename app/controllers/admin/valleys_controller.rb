module Admin
  class ValleysController < Admin::BaseController
    def index
      @valleys = Db::Valley.order(:name)
      @valley = Db::Valley.new
      @peak = Db::Peak.new
    end

    def create
      @valleys = Db::Valley.order(:name)
      @valley = Db::Valley.new(valley_params)
      @peak = Db::Peak.new

      if @valley.save
        redirect_to admin_valleys_path, notice: 'Utworzono doline'
      else
        render :index
      end
    end

    def destroy
      valley = Db::Valley.find(params[:id])
      valley.destroy

      redirect_to admin_valleys_path, notice: 'Usunieto doline'
    end

    private

    def valley_params
      params.require(:valley).permit(:name)
    end
  end
end
