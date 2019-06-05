class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user ||= user || Db::User.new

    default
    not_active if @user.persisted?
    active if @user.active?
    admin if role?('admin')
    secondary_management if role?('secondary_management')
    financial_management if role?('financial_management')
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
    cannot :read, Management::Voting::CaseRecord
  end

  def not_active
    can :manage, Db::Activities::MountainRoute
    can [:read, :update], Settlement::ContractRecord, creator_id: user.id
    can [:read], Settlement::ContractRecord, contract_users: { user_id: user.id }
    cannot :read, Management::Voting::CaseRecord
  end

  def active
    can :read, Management::Voting::CaseRecord, state: 'finished', hidden: false
    can :manage, Db::Activities::MountainRoute
    can :manage, Management::ProjectRecord, project_users: { user_id: user.id }
    can :see_user_name, Db::Activities::MountainRoute
  end

  def routes
    can %i(manage hide), Db::Activities::MountainRoute
  end

  def competitions
    can :manage, Events::Db::SignUpRecord
  end

  def secondary_management
    can :search, Settlement::ContractRecord
    can :create, Training::Supplementary::CourseRecord
    can :read, Settlement::ContractRecord
    can :read, Management::Voting::CaseRecord
    can :manage, Management::ProjectRecord
  end

  def financial_management
    can :accept, Settlement::ContractRecord
  end

  def management
    cannot :accept, Settlement::ContractRecord
    can :search, Settlement::ContractRecord
    can :create, Training::Supplementary::CourseRecord
    can :read, Settlement::ContractRecord
    can :manage, Management::ProjectRecord
    can :manage, Management::Voting::CaseRecord
    can :hide, Management::Voting::CaseRecord
  end

  def events
    can :create, Training::Supplementary::CourseRecord
    can :create, Settlement::ContractRecord
    can :read, Settlement::ContractRecord, creator_id: user.id
  end

  def office_king
    can :search, Settlement::ContractRecord
    cannot :accept, Settlement::ContractRecord
    can :recon_up, Settlement::ContractRecord
    can :manage, Settlement::ContractRecord
    can :manage, Settlement::ContractorRecord
    can :prepayment, Settlement::ContractRecord
  end

  def admin
    can :create, Training::Supplementary::CourseRecord
    can :manage, Db::User
    can :manage, Db::Profile
    can :manage, Events::Db::SignUpRecord
  end

  def office
    can :manage, Db::User
    can :manage, Db::Profile
  end
end
