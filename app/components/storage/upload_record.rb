module Storage
  class UploadRecord < ApplicationRecord
    self.table_name = 'storage_uploads'

    validates :file, presence: true
    validates :user_id, presence: true
    validates :uploadable_id, presence: true
    validates :uploadable_type, presence: true

    belongs_to :uploadable, polymorphic: true
    belongs_to :user, class_name: 'Db::User'

    mount_uploader :file, Storage::FileUploader
  end
end
