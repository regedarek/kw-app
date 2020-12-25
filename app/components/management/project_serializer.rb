module Management
  class ProjectSerializer < ActiveModel::Serializer
    attributes :id, :name, :description, :coordinator,
      :created_at, :needed_knowledge, :benefits, :estimated_time,
      :attachments, :know_how, :state, :slug
  end
end
