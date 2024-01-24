# == Schema Information
#
# Table name: management_informations
#
#  id          :bigint           not null, primary key
#  attachments :string
#  description :text
#  group_type  :integer          default("kw"), not null
#  name        :string           not null
#  news_type   :integer          default("magazine"), not null
#  slug        :string
#  starred     :boolean          default(FALSE), not null
#  url         :string
#  web         :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
module Management
  module News
    class InformationRecord < ActiveRecord::Base
      extend FriendlyId

      self.table_name = 'management_informations'

      enum news_type: [:magazine, :resolution, :annoucement]
      enum group_type: [:kw, :sww, :snw, :stj]
      friendly_id :slug_candidates, use: :slugged

      mount_uploaders :attachments, Management::News::AttachmentUploader
      serialize :attachments, JSON

      def slug_candidates
        [
          [:name],
          [:group_type, :name]
        ]
      end
    end
  end
end
