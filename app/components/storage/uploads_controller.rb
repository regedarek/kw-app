module Storage
  class UploadsController < ApplicationController
    def destroy
      upload = Storage::UploadRecord.find(params[:id])

      authorize! :manage, upload

      upload.destroy
      if upload.uploadable_type == 'Db::Activities::MountainRoute'
        redirect_back(fallback_location: "/przejscia/#{upload.uploadable.slug}", notice: 'Usunięto zdjęcie')
      else
        redirect_back(fallback_location: main_app.root_path, notice: 'Usunięto zdjęcie')
      end
    end

    private

    def upload_params
      params.require(:upload).permit(:user_id, :file, :uploadable_type, :uploadable_id)
    end
  end
end
