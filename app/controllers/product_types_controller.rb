class ProductTypesController < ApplicationController
  before_action :set_product_type, only: [:show, :edit, :update, :destroy]

  def index
    @product_types = Db::ProductType.all
  end

  def show
  end

  def new
    @product_type = Db::ProductType.new
  end

  def edit
  end

  def create
    @product_type = Db::ProductType.new(product_type_params)

    if @product_type.save
      redirect_to @product_type, notice: 'Product type was successfully created.'
    else
      render :new
    end
  end

  def update
    if @product_type.update(product_type_params)
      redirect_to @product_type, notice: 'Product type was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @product_type.destroy
    redirect_to product_types_url, notice: 'Product type was successfully destroyed.'
  end

  private
    def set_product_type
      @product_type = Db::ProductType.find(params[:id])
    end

    def product_type_params
      params.require(:product_type).permit(:name)
    end
end
