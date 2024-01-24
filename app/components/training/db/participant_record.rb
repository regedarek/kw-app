# == Schema Information
#
# Table name: participants
#
#  id             :integer          not null, primary key
#  birth_date     :date
#  birth_place    :string
#  email          :string           not null
#  equipment      :text             default([]), is an Array
#  full_name      :string
#  height         :string
#  phone          :string
#  pre_cost       :string
#  prefered_time  :string           default([]), is an Array
#  recommended_by :text             default([]), is an Array
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  course_id      :integer          not null
#  kw_id          :integer
#
module Training
  module Db
    class ParticipantRecord < ActiveRecord::Base
      RECOMMENDED_BY = %w(google facebook friends festival poster course)
      EQUIPMENT = %w(crampons pickaxe)
      self.table_name = 'participants'

      belongs_to :course, class_name: 'Training::Db::CourseRecord'
    end
  end
end
