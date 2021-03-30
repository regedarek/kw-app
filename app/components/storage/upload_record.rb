module Storage
  class UploadRecord < ActiveRecord::Base
    self.table_name = 'storage_uploads'

    belongs_to :uploadable, polymorphic: true
    belongs_to :user, class_name: 'Db::User', optional: true

    mount_uploader :file, Storage::FileUploader

    def image?
      content_type.start_with?('image')
    end
  end
end
