module Management
  class SettingsRecord < ActiveRecord::Base
    self.table_name = 'settings'
    enum content_type: [:rules, :segment]
  end
end
