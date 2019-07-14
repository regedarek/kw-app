require 'attributed_object'

module Importing
  class LibraryItem
    include ActiveModel::Model
    include AttributedObject::Strict

    attribute :doc_type, :integer
    attribute :title, :string
    attribute :item_id, :integer
    attribute :reading_room, :boolean
    attribute :autors, :string
    attribute :editors, :string
    attribute :year, :integer
  end
end
