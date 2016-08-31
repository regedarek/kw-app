require 'active_model'

module Admin
  class UsersForm
    include ActiveModel::Model

    attr_accessor :kw_id, :first_name, :last_name, :email
  end
end
