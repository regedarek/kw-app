class Like < ActiveRecord::Base
  belongs_to :user, class_name: 'Db::User', foreign_key: :user_id
  belongs_to :likeable, polymorphic: true, counter_cache: true

  validates :user_id, uniqueness: { scope: %i[likeable_id likeable_type] }
end
