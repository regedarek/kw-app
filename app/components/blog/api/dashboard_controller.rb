module Blog
  module Api
    class DashboardController < ApplicationController
      def index
        render json: ::Blog::Dashboard.new.fetch
      end
    end
  end
end
