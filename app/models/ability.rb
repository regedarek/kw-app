class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user ||= user || Db::User.new

    default
    admin if role?('admin')
    routes if role?('routes')
    office if role?('office')
    competitions if role?('competitions')
  end

  def role?(name)
    user.roles.include?(name)
  end

  def default
    can :see_user_name, Db::Activities::MountainRoute if user.persisted?
    cannot :read, Db::Activities::MountainRoute unless user.persisted?
    can %i(manage hide), Db::Activities::MountainRoute, user_id: user.id
    can :create, Db::Profile
  end

  def routes
    can %i(manage hide), Db::Activities::MountainRoute
  end

  def competitions
    can :manage, Events::Db::SignUpRecord
  end

  def admin
    can :manage, Db::User
    can :manage, Db::Profile
    can :manage, Events::Db::SignUpRecord
  end

  def office
    can :manage, Db::User
    can :manage, Db::Profile
  end
end
