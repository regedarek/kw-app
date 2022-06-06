module UserManagement
  class MemberSerializer < ActiveModel::Serializer
    attributes :active

    def active
      Membership::Activement.new(user: self.object).active?
    end
  end
end
