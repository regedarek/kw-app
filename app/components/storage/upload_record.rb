# == Schema Information
#
# Table name: storage_uploads
#
#  id              :bigint           not null, primary key
#  content_type    :string
#  file            :string           not null
#  file_size       :string
#  uploadable_type :string           not null
#  uploadable_id   :integer          not null
#  user_id         :integer
#
# Indexes
#
#  index_storage_uploads_on_uploadable_id_and_uploadable_type  (uploadable_id,uploadable_type)
#  index_storage_uploads_on_user_id                            (user_id)
#
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
