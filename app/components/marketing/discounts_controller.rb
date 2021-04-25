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
        @errors = @discount.errors
        render :new
      end
    end

    def show
      @discount = Marketing::DiscountRecord.friendly.find(params[:id])
    end

    def edit
      @discount = Marketing::DiscountRecord.friendly.find(params[:id])
    end

    def update
      @discount = Marketing::DiscountRecord.friendly.find(params[:id])

      if @discount.update(discount_params)
        redirect_to discount_path(@discount.id), notice: 'Zaktualizowano'
      else
        render :edit
      end
    end

    private

    def discount_params
      params.require(:discount).permit(
        :user_id, :contractor_id, :description, :link, :amount, :amount_type,
        :amount_text, :category_type, :link, attachments: []
      )
    end
  end
end
