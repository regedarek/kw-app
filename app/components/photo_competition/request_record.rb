module PhotoCompetition
  class RequestRecord < ActiveRecord::Base
    self.table_name = 'photo_requests'

    mount_uploader :file, ::PhotoCompetition::FileUploader
    belongs_to :edition, class_name: '::PhotoCompetition::EditionRecord', foreign_key: :edition_record_id
    belongs_to :user, class_name: 'Db::User'
    belongs_to :category, class_name: '::PhotoCompetition::CategoryRecord', foreign_key: :category_record_id

    validates :edition, :user, :category, :description, :file, presence: true
  end
end
