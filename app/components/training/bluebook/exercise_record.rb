module Training
  module Bluebook
    class ExerciseRecord < ActiveRecord::Base
      self.table_name = 'training_exercises'

      enum group_type: [:base, :strength]
    end
  end
end
