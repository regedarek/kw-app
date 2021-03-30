class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user ||= user || Db::User.new

    default
    not_active if @user.persisted?
    active if @user.active?
    active_and_regular if @user.active_and_regular?
    office if role?('office')
    training_contracts if role?('training_contracts')
    competitions if role?('competitions')
    reservations if role?('reservations')
    settings if role?('settings')
    events if role?('events')
    library if role?('library')
    projects if role?('projects')
    business_courses if role?('business_courses')
    marketing if role?('marketing')
    voting if role?('voting')
    admin if role?('admin')

    secondary_management if role?('secondary_management')
    financial_management if role?('financial_management')
    office_king if role?('office_king')
  end

  def role?(name)
    user.roles.include?(name)
  end

  def default
    can :create, Db::Profile
    cannot :read, Management::Voting::CaseRecord
    can :read, Marketing::DiscountRecord
    can :read, Training::Activities::ContractRecord
    cannot :read, Settlement::ContractorRecord
  end

  def library
    can :manage, Library::ItemRecord
  end

  def not_active
    cannot :read, Db::Activities::MountainRoute
    can :manage, Db::Activities::MountainRoute, user_id: user.id
    can [:read, :update], Settlement::ContractRecord, creator_id: user.id
    can [:read], Settlement::ContractRecord, contract_users: { user_id: user.id }
    can :manage, Storage::UploadRecord, uploadable: { user_id: user.id }
    can :manage, Messaging::CommentRecord, user_id: user.id
    cannot :read, Management::Voting::CaseRecord
    cannot :see_dziki, Db::Activities::MountainRoute
    cannot :analiza, Settlement::ContractRecord
  end

  def active
    can :create, Settlement::ContractorRecord
    can :see_dziki, Db::Activities::MountainRoute
    can :create, Db::Profile
    can :read, Shop::OrderRecord
    can :create, Management::Snw::SnwApplyRecord
    can :manage, Management::Snw::SnwApplyRecord, kw_id: user.kw_id
    can :read, Management::Voting::CaseRecord, state: ['unactive', 'voting', 'finished'], hidden: false
    can :read, Db::Activities::MountainRoute
    can :read, Scrappers::ShmuRecord
    can :manage, Db::Activities::MountainRoute, route_colleagues: { colleague_id: user.id }
    cannot :destroy, Db::Activities::MountainRoute, route_colleagues: { colleague_id: user.id }
    can :destroy, Db::Activities::MountainRoute, user_id: user.id
    can :manage, Management::ProjectRecord, project_users: { user_id: user.id }
    can :see_user_name, Db::User
    can :create, Settlement::ContractRecord
    can :manage, Mailboxer::Conversation
    cannot :analiza, Settlement::ContractRecord
  end

  def active_and_regular
    can :create, Management::Voting::VoteRecord
    can :create, Management::Voting::CommissionRecord
  end

  def competitions
    can :manage, Events::Db::SignUpRecord
  end

  def training_contracts
    can :manage, Training::Activities::ContractRecord
  end

  def settings
    can :manage, Management::SettingsRecord
  end

  def voting
    can :obecni, Management::Voting::CaseRecord
    can :approve_for_all, Management::Voting::CaseRecord
    can :manage, Management::Voting::CaseRecord
    can :hide, Management::Voting::CaseRecord
  end

  def events
    can :create, Training::Supplementary::CourseRecord
  end

  def admin
    can :create, Training::Supplementary::CourseRecord
    can :manage, Db::User
    can :manage, Db::Profile
    can :manage, Events::Db::SignUpRecord
    can :manage, PaperTrail::Version
    cannot :destroy, Settlement::ContractRecord
    can :analiza, Settlement::ContractRecord
    can :manage, Management::SettingsRecord
  end

  def projects
    can :manage, Management::ProjectRecord
  end

  def marketing
    can :manage, Settlement::ContractorRecord
    can :create, Marketing::DiscountRecord
    can :manage, Marketing::DiscountRecord
    can :manage, Marketing::SponsorshipRequestRecord
  end

  def office
    can :manage, Settlement::ContractorRecord
    can :manage, Db::User
    can :manage, Shop::OrderRecord
    can :manage, Db::Membership::Fee
    can :manage, Db::Profile
    can :manage, PaperTrail::Version
    can :manage, Management::News::InformationRecord
    can :manage, Management::SettingsRecord
  end

  def business_courses
    can :manage, Business::CourseRecord
    can :manage, Business::SignUpRecord
    can :destroy, Business::SignUpRecord
    can :manage, PaperTrail::Version
  end

  def secondary_management
    can :read, PaperTrail::Version
    can :search, Settlement::ContractRecord
    can :accept, Settlement::ContractRecord
    can :read, Settlement::ContractRecord
    can :update, Settlement::ContractRecord
    can :create, Training::Supplementary::CourseRecord
    can :manage, Management::ProjectRecord
    cannot :destroy, Settlement::ContractRecord
    can :manage, Settlement::ProjectRecord
  end

  def financial_management
    can :read, PaperTrail::Version
    can :search, Settlement::ContractRecord
    can :accept, Settlement::ContractRecord
    can :read, Settlement::ContractRecord
    can :update, Settlement::ContractRecord
    can :prepayment, Settlement::ContractRecord
    cannot :destroy, Settlement::ContractRecord
    can :manage, Settlement::ProjectRecord
  end

  def office_king
    can :read, PaperTrail::Version
    can :read, Settlement::ContractRecord
    can :destroy, Settlement::ContractRecord
    can :update, Settlement::ContractRecord
    can :search, Settlement::ContractRecord
    can :finish, Settlement::ContractRecord
    can :manage, Settlement::ContractorRecord
    can :manage, Settlement::ProjectRecord
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
