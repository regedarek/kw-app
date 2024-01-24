# == Schema Information
#
# Table name: case_presences
#
#  id             :bigint           not null, primary key
#  accepted_terms :boolean          default(FALSE), not null
#  presence_date  :date             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  cerber_id      :integer
#  user_id        :integer          not null
#
# Indexes
#
#  index_case_presences_on_user_id_and_presence_date  (user_id,presence_date) UNIQUE
#
module Management
  module Voting
    class CasePresenceRecord < ActiveRecord::Base
      self.table_name = 'case_presences'

      belongs_to :user, class_name: 'Db::User'
      belongs_to :cerber, class_name: 'Db::User', optional: true

      validates :user_id, uniqueness: { scope: :presence_date }
    end
  end
end
