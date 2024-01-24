# == Schema Information
#
# Table name: club_meetings_ideas
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string           not null
#  slug        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_club_meetings_ideas_on_name     (name) UNIQUE
#  index_club_meetings_ideas_on_slug     (slug) UNIQUE
#  index_club_meetings_ideas_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
module ClubMeetings
  class IdeaRecord < ActiveRecord::Base
    self.table_name = 'club_meetings_ideas'
    extend FriendlyId

    friendly_id :slug_candidates, use: :slugged

    belongs_to :user, class_name: 'Db::User', foreign_key: 'user_id'

    validates :name, presence: true, uniqueness: true
    validates :slug, presence: true, uniqueness: true
    validates :user, presence: true

    has_many :photos, as: :uploadable, class_name: 'Storage::UploadRecord'
    accepts_nested_attributes_for :photos

    def slug_candidates
      [
        [:name, :year]
      ]
    end

    def year
      Date.today.year
    end
  end
end
