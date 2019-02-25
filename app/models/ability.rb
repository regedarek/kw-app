class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user ||= user || Db::User.new

    default
    not_active if @user.persisted?
    active if @user.active?
    admin if role?('admin')
    management if role?('management')
    office_king if role?('office_king')
    routes if role?('routes')
    office if role?('office')
    competitions if role?('competitions')
    events if role?('events')
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

  def management
    can :read, Settlement::ContractRecord
    can :accept, Settlement::ContractRecord
  end

  def events
    can :create, Settlement::ContractRecord
    can :read, Settlement::ContractRecord
  end

  def office_king
    can :manage, Settlement::ContractRecord
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
