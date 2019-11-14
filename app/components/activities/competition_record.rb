module Activities
  class CompetitionRecord < ActiveRecord::Base
    include Workflow
    include ActionView::Helpers::AssetTagHelper
    extend FriendlyId
    self.table_name = 'activities_competitions'

    enum country: [
      :poland, :slovakia, :italy, :france, :austria, :czech, :deutchland, :switzerland, :andorra
    ]

    friendly_id :slug_candidates, use: :slugged

    workflow_column :state
    workflow do
      state :draft do
        event :open, :transitions_to => :ready
      end
      state :ready
    end

    def self.country_attributes_for_select
      countries.map do |activity_type, _|
        [activity_type, activity_type]
      end
    end

    def slug_candidates
      [
        [:start_date, :name]
      ]
    end
  end
end
