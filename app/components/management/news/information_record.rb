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
