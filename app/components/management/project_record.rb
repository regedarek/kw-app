module Management
  class ProjectRecord < ActiveRecord::Base
    self.table_name = 'projects'

    has_many :project_users, class_name: 'Management::ProjectUsersRecord', foreign_key: :project_id
    has_many :users, through: :project_users, foreign_key: :user_id, dependent: :destroy

    def coordinator
      ::Db::User.find(coordinator_id)
    end

    def users_names=(ids)
      self.user_ids = ids
    end

    attr_reader :users_names
  end
end
