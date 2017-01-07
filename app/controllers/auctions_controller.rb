class AuctionsController < ApplicationController
  def index
    @auctions = Db::Auction.where(archived: false)
  end

  def new
    @auction = Db::Auction.new
    @auction.auction_products.build
  end

  def create
    redirect_to auctions_path unless user_signed_in?

    @auction = Db::Auction.new(auction_params)
    @auction.user_id = current_user.id

    if @auction.save
      redirect_to auctions_path, notice: 'Utworzono.'
    else
      render :new
    end
  end

  def show
    @auction = Db::Auction.find(params[:id])
  end

  def mark_archived
    auction = Db::Auction.find(params[:id])
    auction.update(archived: true)

    redirect_to auctions_path, notice: 'Zarchiwizowano'
  end

  private

  def auction_params
    params
      .require(:auction)
      .permit(
        :name, :description,
        auction_products_attributes: [:id, :name, :price, :description, :_destroy]
      )
  end
end
