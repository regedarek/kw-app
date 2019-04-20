class PhotosController < ApplicationController
  def index
    respond_to do |format|
      format.html { render "photos/index", layout: false }
    end
  end
end
