module Admin
  class ImportingController < Admin::BaseController
    def index
    end

    def import
      uploader = CsvUploader.new
      uploader.cache!(import_params.fetch(:file))

      result = Importing::FromCsv.import(file: uploader.file, type: import_params.fetch(:type))
      result.success { redirect_to admin_importing_index_path, notice: t('.imported') }
      result.invalid do |message|
        redirect_to admin_importing_index_path, alert: t('.not_imported', message: message.fetch(:message))
      end
      result.else_fail!

      uploader.remove!
    end

    private

    def import_params
      params.permit(:file, :type)
    end
  end
end
