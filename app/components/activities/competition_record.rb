module Activities
  class CompetitionRecord < ActiveRecord::Base
    include Workflow
    include ActionView::Helpers::AssetTagHelper
    extend FriendlyId
    self.table_name = 'activities_competitions'

    enum country: [
      :poland, :slovakia, :italy, :france, :austria, :czech, :deutchland, :switzerland, :andorra, :china, :ukraine, :spain, :sweden, :usa, :greece
    ]

    enum series: [
      :pp, :ismf, :lgc
    ]

    friendly_id :slug_candidates, use: :slugged

    validates :name, :country, :state, presence: true
    validates :name, :uniqueness => {:scope => [:start_date], message: ' => Zawody o tej nazwie zostały już dodane w tym terminie.'}

    workflow_column :state
    workflow do
      state :draft do
        event :open, :transitions_to => :ready
      end
      state :ready
    end

    def flag_sym
      case country.to_sym
      when :greece
        :gr
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
        :ad
      when :ukraine
        :ua
      when :china
        :cn
      when :spain
        :es
      when :sweden
        :se
      when :usa
        :us
      else
        :en
      end
    end

    def self.country_attributes_for_select
      countries.map do |activity_type, _|
        [activity_type, activity_type]
      end
    end

    def self.series_attributes_for_select
      series.map do |activity_type, _|
        [I18n.t("activerecord.attributes.#{model_name.i18n_key}.series.#{activity_type}"), activity_type]
      end
    end

    def slug_candidates
      [
        [:start_date, :name]
      ]
    end

    def to_params

    end
  end
end
