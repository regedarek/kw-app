module Management
  module News
    class InformationRecord < ActiveRecord::Base
      self.table_name = 'management_informations'

      enum news_type: [:magazine, :resolution, :annoucement]
      enum group_type: [:kw, :sww, :snw, :stj]
    end
  end
end
