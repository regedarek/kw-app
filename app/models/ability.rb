class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user ||= user || Db::User.new

    default
    admin if role?('admin')
    office if role?('office')
  end

  def role?(name)
    user.roles.include?(name)
  end

  def default
    can %i(read create), Db::Activities::MountainRoute
  end

  def admin
    can %i(manage hide), Db::Activities::MountainRoute
    can :manage, Db::User
  end

  def office
    can :manage, Db::User
  end
end
