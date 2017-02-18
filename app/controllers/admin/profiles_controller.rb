module Admin
  class ProfilesController < Admin::BaseController
    def index
      @profiles = Db::Profile.all
    end
  end
end
