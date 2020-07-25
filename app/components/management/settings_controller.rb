module Management
  class SettingsController < ApplicationController
    include EitherMatcher
    append_view_path 'app/components'

    def index
      authorize! :manage, Management::SettingsRecord

      @settings = Management::SettingsRecord.all
    end

    def edit
      authorize! :manage, Management::SettingsRecord

      @setting = Management::SettingsRecord.find(params[:id])
    end

    def update
      authorize! :manage, Management::SettingsRecord

      @setting = Management::SettingsRecord.find(params[:id])

      if @setting.update(setting_params)
        redirect_to edit_setting_path, notice: 'Saved'
      else
        render :edit
      end
    end

    private

    def setting_params
      params.require(:setting).permit(:name, :content, :back_url, :path)
    end
  end
end
