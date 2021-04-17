class AddConversationAtToSupplementaryCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :supplementary_courses, :conversation_at, :datetime
  end
end
