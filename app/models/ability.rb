class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user ||= user || Db::User.new

    default
    not_active if @user.persisted?
    active if @user.active?
    admin if role?('admin')
    routes if role?('routes')
    office if role?('office')
    competitions if role?('competitions')
  end

  def role?(name)
    user.roles.include?(name)
  end

  def default
    can :create, Db::Profile
  end

  def not_active
    can :manage, Db::Activities::MountainRoute
  end

  def active
    can :manage, Db::Activities::MountainRoute
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
