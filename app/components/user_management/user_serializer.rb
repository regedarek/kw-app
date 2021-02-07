module UserManagement
  class UserSerializer < ActiveModel::Serializer
    attributes :id, :gender, :first_name, :last_name, :display_name, :email, :avatar, :description, :slug, :kw_id
  end
end
