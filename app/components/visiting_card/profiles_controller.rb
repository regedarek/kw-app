module VisitingCard
  class ProfilesController < ApplicationController
    append_view_path 'app/components'

    def show
      @profile = Db::Profile.find(params[:id])
    end
  end
end
