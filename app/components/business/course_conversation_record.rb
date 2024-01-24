# == Schema Information
#
# Table name: business_course_conversations
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  conversation_id :integer          not null
#  course_id       :integer          not null
#
# Indexes
#
#  business_course_conversations_uniq  (course_id,conversation_id) UNIQUE
#
module Business
  class CourseConversationRecord < ActiveRecord::Base
    self.table_name = 'business_course_conversations'

    belongs_to :conversation, class_name: 'Mailboxer::Conversation', foreign_key: :conversation_id
    belongs_to :course, class_name: 'Business::CourseRecord', foreign_key: :course_id
  end
end
