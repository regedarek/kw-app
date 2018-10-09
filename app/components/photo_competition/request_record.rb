module PhotoCompetition
  class RequestRecord < ActiveRecord::Base
    self.table_name = 'photo_requests'

    mount_uploader :file, ::PhotoCompetition::FileUploader
    belongs_to :edition, class_name: '::PhotoCompetition::EditionRecord', foreign_key: :edition_record_id
    belongs_to :user, class_name: 'Db::User'
    belongs_to :category, class_name: '::PhotoCompetition::CategoryRecord', foreign_key: :category_record_id

    validates :edition, :user, :category, :file, presence: true
    validates :title, presence: true, if: :title_needed?
    validates :area, presence: true, if: :area_needed?
    validates :description, presence: true, if: :description_needed?

    def description_needed?
      category && category.mandatory_fields.include?('description')
    end

    def title_needed?
      category && category.mandatory_fields.include?('title')
    end

    def area_needed?
      category && category.mandatory_fields.include?('area')
    end
  end
end
