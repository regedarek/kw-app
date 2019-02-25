module Settlement
  class ContractRecord < ActiveRecord::Base
    include Workflow

    mount_uploaders :attachments, AttachmentUploader
    serialize :attachments, JSON

    self.table_name = 'contracts'

    belongs_to :acceptor, class_name: 'Db::User', foreign_key: :acceptor_id

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
  end
end
