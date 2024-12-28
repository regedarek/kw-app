module ProfileCreation
  module V2
    class ProfilesController < ApplicationController
      append_view_path 'app/components'

      def new
        @profile = Db::Profile.new
      end

      def create
      end
    end
  end
end
