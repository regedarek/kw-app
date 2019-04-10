module Management
  class ProjectRecord < ActiveRecord::Base
    self.table_name = 'projects'

    def coordinator
      ::Db::User.find(coordinator_id)
    end
  end
end
