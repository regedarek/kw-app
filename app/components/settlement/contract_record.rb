module Settlement
  class ContractRecord < ActiveRecord::Base
    include Workflow

    enum document_type: [:fv, :work, :service, :bill, :volunteering, :charities, :taxes]
    enum group_type: [:snw, :gtw, :sww, :stj]
    mount_uploaders :attachments, Settlement::AttachmentUploader
    serialize :attachments, JSON

    self.table_name = 'contracts'

    belongs_to :acceptor, class_name: 'Db::User', foreign_key: :acceptor_id
    belongs_to :creator, class_name: 'Db::User', foreign_key: :creator_id

    has_many :contract_users, class_name: 'Settlement::ContractUsersRecord', foreign_key: :contract_id
    has_many :users, through: :contract_users, foreign_key: :user_id, dependent: :destroy
    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'

    workflow_column :state
    workflow do
      state :new do
        event :accept, :transitions_to => :accepted
      end
      state :rejected
      state :accepted do
        event :prepayment, :transitions_to => :closed
      end
      state :closed
    end

    def users_names=(ids)
      self.user_ids = ids
    end

    attr_reader :users_names
  end
end
