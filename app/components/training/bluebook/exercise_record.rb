# == Schema Information
#
# Table name: training_exercises
#
#  id          :bigint           not null, primary key
#  description :text
#  group_type  :integer
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
module Training
  module Bluebook
    class ExerciseRecord < ActiveRecord::Base
      self.table_name = 'training_exercises'

      enum group_type: [:base, :strength]
    end
  end
end
