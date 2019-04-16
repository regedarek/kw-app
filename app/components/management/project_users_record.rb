module Management
  class ProjectUsersRecord < ActiveRecord::Base
    self.table_name = 'project_users'

    belongs_to :user, class_name: 'Db::User', foreign_key: :user_id, inverse_of: :project_users
    belongs_to :project, class_name: 'Management::ProjectRecord', foreign_key: :project_id, inverse_of: :project_users
  end
end
