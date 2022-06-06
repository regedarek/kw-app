module UserManagement
  class MemberSerializer < ActiveModel::Serializer
    attributes :kw_id, :display_name, :active

    def active
      Membership::Activement.new(user: self.object).active?
    end
  end
end
