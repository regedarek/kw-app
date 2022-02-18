module Library
  class ItemRecord < ActiveRecord::Base
    extend FriendlyId
    self.table_name = 'library_items'

    enum doc_type: [:book, :magazine, :guide]

    mount_uploaders :attachments, Library::AttachmentUploader
    serialize :attachments, JSON

    friendly_id :title, use: :slugged

    has_many :item_authors, class_name: '::Library::ItemAuthorsRecord', foreign_key: :item_id
    has_many :authors, class_name: '::Library::AuthorRecord', through: :item_authors, foreign_key: :author_id, dependent: :destroy

    has_many :library_item_reservations, class_name: '::Library::ItemReservationRecord', foreign_key: :item_id
    has_many :library_reservators, class_name: '::Db::User', through: :library_item_reservations, foreign_key: :user_id, dependent: :destroy, source: :user

    has_many :item_tags, class_name: '::Library::ItemTagsRecord', foreign_key: :item_id
    has_many :tags, class_name: '::Library::TagRecord', through: :item_tags, foreign_key: :tag_id, dependent: :destroy

    def authors_names=(ids)
      self.author_ids = ids
    end
    attr_reader :authors_names
  end
end
