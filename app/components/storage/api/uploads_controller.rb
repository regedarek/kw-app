module Storage
  module Api
    class UploadsController < ApplicationController
      def create
        upload = Storage::UploadRecord.new(upload_params)

        if upload.save
          render json: upload
        else
          render json: upload.errors
        end
      end

      def destroy
        upload = Storage::UploadRecord.find(params[:id])

        upload.destroy
        render json: upload, code: 200
      end

      private

      def upload_params
        params.require(:upload).permit(:user_id, :file, :uploadable_type, :uploadable_id)
      end
    end
  end
end
