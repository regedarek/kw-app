module Blog
  module Api
    class AuthorsController < ApplicationController
      def index
        render json: ::Blog::Authors.new.fetch
      end

      def show
        render json: ::Blog::Authors.new.fetch_one(number: params[:id])
      end
    end
  end
end
