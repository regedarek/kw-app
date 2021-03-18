module Settlement
  class ContractRecord < ActiveRecord::Base
    has_paper_trail
    include Workflow

    enum document_type: [:fv, :work, :service, :bill, :volunteering, :charities, :taxes]
    enum financial_type: [:opp_paid, :opp_unpaid, :administration, :charity, :economic_activity]
    enum substantive_type: [:office, :substantive_taxes, :marketing, :integration, :climbing_course, :avalanche_course, :first_aid_course, :stj_course, :supplementary_training, :egg, :christmas_eve]
    enum group_type: [:kw, :snw, :sww, :stj]
    enum event_type: [:not, :other, :mjs, :mas, :mo, :kfg]
    enum payout_type: [:to_contractor, :return]

    mount_uploaders :attachments, Settlement::AttachmentUploader
    serialize :attachments, JSON

    self.table_name = 'contracts'

    belongs_to :acceptor, class_name: 'Db::User', foreign_key: :acceptor_id
    belongs_to :creator, class_name: 'Db::User', foreign_key: :creator_id
    belongs_to :contractor, class_name: 'Settlement::ContractorRecord', foreign_key: :contractor_id

    has_many :contract_events, class_name: 'Settlement::ContractEventsRecord', foreign_key: :contract_id
    has_many :events, class_name: 'Training::Supplementary::CourseRecord', through: :contract_events, foreign_key: :event_id, dependent: :destroy

    has_many :contract_users, class_name: 'Settlement::ContractUsersRecord', foreign_key: :contract_id
    has_many :users, through: :contract_users, foreign_key: :user_id, dependent: :destroy

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    has_many :project_items, as: :accountable, class_name: '::Settlement::ProjectItemRecord'
    has_many :projects, through: :project_items

    workflow_column :state
    workflow do
      state :new do
        event :accept, :transitions_to => :accepted
      end
      state :rejected
      state :accepted do
        event :prepayment, :transitions_to => :preclosed
      end
      state :preclosed do
        event :finish, :transitions_to => :closed
      end
      state :closed
    end

    def contractor_name=(id)
      self.contractor_id = id
    end

    attr_reader :contractor_name
  end
end
