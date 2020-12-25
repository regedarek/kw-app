module Management
  module News
    class InformationSerializer < ActiveModel::Serializer
      attributes :id, :name, :description, :url, :news_type, :created_at, :group_type, :web, :starred
    end
  end
end
