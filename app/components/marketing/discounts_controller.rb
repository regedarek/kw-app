module Marketing
  class DiscountsController < ApplicationController
    append_view_path 'app/components'

    def index
      @discounts = Marketing::DiscountRecord.includes(:user, :contractor).all
    end

    def new
      @discount = Marketing::DiscountRecord.new
    end

    def create
      @discount = Marketing::DiscountRecord.new(discount_params)

      if @discount.save
        redirect_to discounts_path, notice: 'Dodano'
      else
        render :new
      end
    end

    def show
      @discount = Marketing::DiscountRecord.friendly.find(params[:id])
    end

    private

    def discount_params
      params.require(:discount).permit(:user_id, :contractor_id, :description, :link, :amount, :amount_type, :category_type, :link, attachments: [])
    end
  end
end
