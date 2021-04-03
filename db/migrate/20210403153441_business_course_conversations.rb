class BusinessCourseConversations < ActiveRecord::Migration[5.2]
  def change
    create_table :business_course_conversations do |t|
      t.integer :course_id, null: false
      t.integer :conversation_id, null: false
      t.timestamps null: false
    end

    add_index :business_course_conversations, [:course_id, :conversation_id], unique: true, name: 'business_course_conversations_uniq'
  end
end
