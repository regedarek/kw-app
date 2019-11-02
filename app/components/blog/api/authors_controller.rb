module Blog
  module Api
    class AuthorsController < ApplicationController
      def index
        render json: ::Blog::Authors.new.fetch
      end
    end
  end
end
