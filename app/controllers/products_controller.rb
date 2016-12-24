class ProductsController < ApplicationController
  def index
    @products = Db::Product.all
  end

  def new
    @product = Db::Product.new
  end

  def create
    @product = Db::Product.new(product_params)

    if @product.save
      redirect_to products_path, notice: 'Utworzono.'
    else
      render :new
    end
  end

  def show
    @product = Db::Product.find(params[:id])
  end

  private

  def product_params
    params.require(:product).permit(:name, :description)
  end
end
