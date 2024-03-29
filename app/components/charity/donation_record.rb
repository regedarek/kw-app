# == Schema Information
#
# Table name: donations
#
#  id           :integer          not null, primary key
#  action_type  :integer
#  cost         :integer
#  description  :string
#  display_name :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :integer
#
# Indexes
#
#  index_donations_on_user_id  (user_id)
#
module Charity
  class DonationRecord < ActiveRecord::Base
    self.table_name = 'donations'
    has_one :payment, as: :payable, dependent: :destroy, class_name: 'Db::Payment'
    belongs_to :user, class_name: 'Db::User'

    enum action_type: [:mariusz, :crack, :ski_service]

    validates_acceptance_of :terms_of_service

    def payment_type
      if crack? || ski_service?
        :trainings
      else
        :donations
      end
    end

    def self.action_types_select
      Charity::DonationRecord.action_types.map { |w, _| [I18n.t(w, scope: 'activerecord.attributes.charity/donation_record.action_types'), w] }
    end
  end
end
