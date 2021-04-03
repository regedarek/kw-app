module Business
  class CourseConversationRecord < ActiveRecord::Base
    self.table_name = 'business_course_conversations'

    belongs_to :conversation, class_name: 'Mailboxer::Conversation', foreign_key: :conversation_id
    belongs_to :course, class_name: 'Business::CourseRecord', foreign_key: :course_id
  end
end
