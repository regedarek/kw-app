module Management
  class ProjectSerializer < ActiveModel::Serializer
    attributes :id, :name, :description,
      :created_at, :needed_knowledge, :benefits, :estimated_time,
      :attachments, :know_how, :state, :slug, :group_type

    belongs_to :coordinator, serializer: UserManagement::UserSerializer
    has_many :users, serializer: UserManagement::UserSerializer
  end
end
