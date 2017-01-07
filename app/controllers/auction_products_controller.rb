class AuctionProductsController < ApplicationController
  def new
    @auction_product = Db::AuctionProduct.new
    render :new, layout: false
  end

  def mark_sold
    product = Db::AuctionProduct.find(params[:id])
    product.update(sold: true)

    redirect_to auction_path(product.auction), notice: 'Oznaczono'
  end
end
