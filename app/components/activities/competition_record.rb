module Activities
  class CompetitionRecord < ActiveRecord::Base
    include Workflow
    include ActionView::Helpers::AssetTagHelper
    extend FriendlyId
    self.table_name = 'activities_competitions'

    enum country: [
      :poland, :slovakia, :italy, :france, :austria, :czech, :deutchland, :switzerland, :andorra, :china
    ]

    friendly_id :slug_candidates, use: :slugged

    validates :name, :country, :state, presence: true

    workflow_column :state
    workflow do
      state :draft do
        event :open, :transitions_to => :ready
      end
      state :ready
    end

    def flag_link
      case country.to_sym
      when :poland
        'https://raw.githubusercontent.com/evgenygarl/flag-icons-rails/master/app/assets/images/flags/1x1/sk.svg'
      when :slovakia
        'https://raw.githubusercontent.com/evgenygarl/flag-icons-rails/master/app/assets/images/flags/1x1/sk.svg'
      when :italy
        'https://raw.githubusercontent.com/evgenygarl/flag-icons-rails/master/app/assets/images/flags/1x1/sk.svg'
      when :france
        'https://raw.githubusercontent.com/evgenygarl/flag-icons-rails/master/app/assets/images/flags/1x1/sk.svg'
      when :austria
        'https://raw.githubusercontent.com/evgenygarl/flag-icons-rails/master/app/assets/images/flags/1x1/sk.svg'
      when :czech
        'https://raw.githubusercontent.com/evgenygarl/flag-icons-rails/master/app/assets/images/flags/1x1/sk.svg'
      when :deutchland
        'https://raw.githubusercontent.com/evgenygarl/flag-icons-rails/master/app/assets/images/flags/1x1/sk.svg'
      when :switzerland
        'https://raw.githubusercontent.com/evgenygarl/flag-icons-rails/master/app/assets/images/flags/1x1/sk.svg'
      when :andorra
        'https://raw.githubusercontent.com/evgenygarl/flag-icons-rails/master/app/assets/images/flags/1x1/sk.svg'
      when :china
        'https://raw.githubusercontent.com/evgenygarl/flag-icons-rails/master/app/assets/images/flags/1x1/sk.svg'
      else
        'https://raw.githubusercontent.com/evgenygarl/flag-icons-rails/master/app/assets/images/flags/1x1/sk.svg'
      end
    end

    def flag_sym
      case country.to_sym
      when :poland
        :pl
      when :slovakia
        :sk
      when :italy
        :it
      when :france
        :fr
      when :austria
        :at
      when :czech
        :cz
      when :deutchland
        :de
      when :switzerland
        :ch
      when :andorra
        :ar
      when :china
        :cn
      else
        :en
      end
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
