module YearlyPrize
  module Admin
    class YearlyPrizeEditionsController < ::Admin::BaseController
      append_view_path 'app/components'

      def index
        @editions = Db::YearlyPrizeEdition.order(updated_at: :desc)
      end

      def create
        if @edition = Db::YearlyPrizeEdition.create_with_categories(edition_params[:year])
          redirect_to admin_yearly_prize_editions_path, notice: 'Edition was successfully created.'
        else
          render :new
        end
      end

      def show
        @edition = Db::YearlyPrizeEdition.find(params[:id])
      end

      def edit
        @edition = Db::YearlyPrizeEdition.find(params[:id])
      end

      def update
        @edition = Db::YearlyPrizeEdition.find(params[:id])

        if @edition.update(edition_params)
          redirect_to admin_yearly_prize_editions_path, notice: 'Edition was successfully updated.'
        else
          render :edit
        end
      end

      private

      def edition_params
        params.require(:yearly_prize_edition).permit(:name, :year, :closed, :description, :start_voting_date, :end_voting_date)
      end
    end
  end
end
