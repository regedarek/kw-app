module Business
  class CourseRecord < ActiveRecord::Base
    include Workflow
    extend FriendlyId

    friendly_id :name, use: :slugged
    self.table_name = 'business_courses'
    enum activity_type: [
      :winter_abc, :winter_tourist_1, :winter_tourist_2,
      :skitour_1, :skitour_2, :skitour_3, :cave, :climbing_1,
      :climbing_2, :full_climbing, :summer_tatra, :winter_tatra_1,
      :winter_tatra_2, :ice_1, :ice_2, :club_climbing
    ]

    workflow_column :state
    workflow do
      state :draft do
        event :open, :transitions_to => :ready
      end
      state :ready
    end

    def self.activity_type_attributes_for_select
      activity_types.map do |activity_type, _|
        [I18n.t("activerecord.attributes.#{model_name.i18n_key}.activity_types.#{activity_type}"), activity_type]
      end
    end
  end
end
