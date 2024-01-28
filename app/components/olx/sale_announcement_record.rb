# == Schema Information
#
# Table name: sale_announcements
#
#  id          :bigint           not null, primary key
#  archived    :boolean          default(FALSE), not null
#  description :text
#  name        :string           not null
#  price       :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint
#
# Indexes
#
#  index_sale_announcements_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
module Olx
  class SaleAnnouncementRecord < ActiveRecord::Base
    self.table_name = 'sale_announcements'

    belongs_to :user, class_name: 'Db::User', foreign_key: 'user_id'

    validates :name, presence: true

    has_many :photos, as: :uploadable, class_name: 'Storage::UploadRecord', dependent: :destroy
    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    accepts_nested_attributes_for :photos

    def primary_photo
      photos.first
    end
  end
end
