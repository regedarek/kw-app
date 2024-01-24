# == Schema Information
#
# Table name: library_tags
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string
#  type        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  parent_id   :integer
#
module Library
  class TagRecord < ActiveRecord::Base
    self.table_name = 'library_tags'

    has_many :item_tags, class_name: '::Library::ItemTagsRecord', foreign_key: :tag_id
    has_many :items, class_name: '::Library::ItemRecord', through: :item_tags, foreign_key: :item_id, dependent: :destroy
  end
end
