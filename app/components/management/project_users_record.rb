# == Schema Information
#
# Table name: project_users
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_project_users_on_project_id_and_user_id  (project_id,user_id) UNIQUE
#
module Management
  class ProjectUsersRecord < ActiveRecord::Base
    self.table_name = 'project_users'

    belongs_to :user, class_name: 'Db::User', foreign_key: :user_id, inverse_of: :project_users
    belongs_to :project, class_name: 'Management::ProjectRecord', foreign_key: :project_id, inverse_of: :project_users
  end
end
