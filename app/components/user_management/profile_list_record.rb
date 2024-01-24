# == Schema Information
#
# Table name: profile_lists
#
#  id           :bigint           not null, primary key
#  accepted     :boolean          default(FALSE), not null
#  attachments  :string
#  description  :text
#  section_type :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  acceptor_id  :integer
#  profile_id   :integer          not null
#
module UserManagement
  class ProfileListRecord < ActiveRecord::Base
    self.table_name = 'profile_lists'

    enum section_type: [:snw, :sww]

    mount_uploaders :attachments, AttachmentUploader
    serialize :attachments, JSON

    validates_presence_of :description, :section_type

    belongs_to :profile, class_name: "Db::Profile"

    def section_types
      UserManagement::ProfileListRecord.section_types.keys.map do |key,value|
        [
          I18n.t("user_management.list.enums.section_types.#{key}").humanize,
          key.to_sym
        ]
      end
    end
  end
end
