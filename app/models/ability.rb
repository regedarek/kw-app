class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user ||= user || Db::User.new

    default
    not_active if @user.persisted?
    active if @user.active?
    office if role?('office')
    training_contracts if role?('training_contracts')
    competitions if role?('competitions')
    reservations if role?('reservations')
    events if role?('events')
    library if role?('library')
    secondary_management if role?('secondary_management')
    business_courses if role?('business_courses')
    financial_management if role?('financial_management')
    management if role?('management')
    voting if role?('voting')
    admin if role?('admin')
    office_king if role?('office_king')
  end

  def role?(name)
    user.roles.include?(name)
  end

  def default
    can :create, Db::Profile
    cannot :read, Management::Voting::CaseRecord
    can :read, Training::Activities::ContractRecord
  end

  def library
    can :manage, Library::ItemRecord
  end

  def not_active
    can :manage, Db::Activities::MountainRoute, user_id: user.id
    can [:read, :update], Settlement::ContractRecord, creator_id: user.id
    can [:read], Settlement::ContractRecord, contract_users: { user_id: user.id }
    cannot :read, Management::Voting::CaseRecord
  end

  def active
    can :create, Db::Profile
    can :create, Management::Snw::SnwApplyRecord
    can :manage, Management::Snw::SnwApplyRecord, kw_id: user.kw_id
    can :read, Management::Voting::CaseRecord, state: 'finished', hidden: false
    can :read, Db::Activities::MountainRoute
    can :read, Scrappers::ShmuRecord
    can :manage, Db::Activities::MountainRoute, route_colleagues: { colleague_id: user.id }
    cannot :destroy, Db::Activities::MountainRoute, route_colleagues: { colleague_id: user.id }
    can :destroy, Db::Activities::MountainRoute, user_id: user.id
    can :manage, Management::ProjectRecord, project_users: { user_id: user.id }
    can :see_user_name, Db::User
    can :create, Settlement::ContractRecord
    can :manage, Mailboxer::Conversation
  end

  def competitions
    can :manage, Events::Db::SignUpRecord
  end

  def training_contracts
    can :manage, Training::Activities::ContractRecord
  end

  def secondary_management
    can :search, Settlement::ContractRecord
    can :create, Training::Supplementary::CourseRecord
    can :read, Settlement::ContractRecord
    can :read, Management::Voting::CaseRecord
    can :create, Management::Voting::CaseRecord
    can :manage, Management::ProjectRecord
    cannot :destroy, Settlement::ContractRecord
    can :manage, Management::Snw::SnwApplyRecord
  end

  def management
    can :search, Settlement::ContractRecord
    can :create, Training::Supplementary::CourseRecord
    can :read, Settlement::ContractRecord
    can :manage, Management::ProjectRecord
    can :manage, PaperTrail::Version
    cannot :destroy, Settlement::ContractRecord
    can :approve, Management::Voting::CaseRecord
  end

  def voting
    can :approve_for_all, Management::Voting::CaseRecord
    can :manage, Management::Voting::CaseRecord
    can :hide, Management::Voting::CaseRecord
  end

  def events
    can :create, Training::Supplementary::CourseRecord
    can :create, Settlement::ContractRecord
    can :read, Settlement::ContractRecord, creator_id: user.id
  end

  def financial_management
    can :accept, Settlement::ContractRecord
    cannot :destroy, Settlement::ContractRecord
    can :manage, PaperTrail::Version
    can :approve, Management::Voting::CaseRecord
  end

  def admin
    can :create, Training::Supplementary::CourseRecord
    can :manage, Db::User
    can :manage, Db::Profile
    can :manage, Events::Db::SignUpRecord
    can :manage, PaperTrail::Version
    cannot :destroy, Settlement::ContractRecord
  end

  def office
    can :manage, Db::User
    can :manage, Db::Membership::Fee
    can :manage, Db::Profile
    cannot :destroy, Settlement::ContractRecord
    can :manage, PaperTrail::Version
  end

  def business_courses
    can :manage, Business::CourseRecord
    can :manage, PaperTrail::Version
  end

  def office_king
    can :destroy, Settlement::ContractRecord
    can :search, Settlement::ContractRecord
    can :recon_up, Settlement::ContractRecord
    can :create, Settlement::ContractRecord
    can :manage, PaperTrail::Version
    can :manage, Settlement::ContractRecord
    cannot :accept, Settlement::ContractRecord
    can :manage, Settlement::ContractorRecord
    can :prepayment, Settlement::ContractRecord
  end

  def reservations
    can :manage, Db::Reservation
    can :give_warning, Db::Reservation
    can :give_back_warning, Db::Reservation
    can :remind, Db::Reservation
    can :charge, Db::Reservation
    can :give, Db::Reservation
    can :archive, Db::Reservation
  end
end
