# == Schema Information
#
# Table name: emails
#
#  id            :bigint           not null, primary key
#  delivered_at  :datetime
#  mailable_type :string           not null
#  state         :string           default("sent")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  mailable_id   :integer          not null
#  message_id    :string           not null
#
module EmailCenter
  class EmailRecord < ActiveRecord::Base
    include Workflow
    self.table_name = 'emails'

    scope :delivered, -> { where.not(delivered_at: nil) }
    scope :recent, -> { order(created_at: :desc).limit(5) }

    belongs_to :mailable, polymorphic: true

    workflow_column :state
    workflow do
      state :sent do
        event :deliver, :transitions_to => :delivered
      end
      state :delivered
    end
  end
end
