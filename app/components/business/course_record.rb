module Business
  class CourseRecord < ActiveRecord::Base
    include Workflow
    include ActionView::Helpers::AssetTagHelper
    extend FriendlyId
    self.table_name = 'business_courses'

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'
    belongs_to :instructor, class_name: '::Business::InstructorRecord', foreign_key: :instructor_id
    belongs_to :coordinator, class_name: '::Db::User', foreign_key: :coordinator_id

    validates :seats, numericality: { greater_than_or_equal_to: 0, message: 'Minimum to 0' }
    validates :max_seats, presence: true
    validates :sign_up_url, presence: true
    validates :activity_type, presence: true
    validate :max_seats_size

    friendly_id :slug_candidates, use: :slugged

    enum activity_type: [
      :winter_abc, :winter_tourist_1, :winter_tourist_2,
      :skitour_1, :skitour_2, :skitour_3, :skitour_avalanche, :skitour_avalanche_2,
      :climbing_1, :climbing_2, :full_climbing, :summer_tatra, :club_climbing,
      :winter_tatra_1, :winter_tatra_2, :ice_1, :ice_2,
      :cave
    ]

    def slug_candidates
      [
        [:starts_at, :name]
      ]
    end

    workflow_column :state
    workflow do
      state :draft do
        event :open, :transitions_to => :ready
      end
      state :ready
    end

    def max_seats_size
      if max_seats.present?
        if self.seats > self.max_seats
          errors.add(:seats, 'Przekroczono limit miejsc')
        end
      end
    end

    def self.activity_type_attributes_for_select
      activity_types.map do |activity_type, _|
        [I18n.t("activerecord.attributes.#{model_name.i18n_key}.activity_types.#{activity_type}"), activity_type]
      end
    end

    def activity_url
      case activity_type.to_sym
      when :winter_abc
        'https://szkolaalpinizmu.pl/turystyka/zimowe-abc/'
      when :winter_tourist_1
        'https://szkolaalpinizmu.pl/turystyka/turystyka-zimowa-ist/'
      when :winter_tourist_2
        'https://szkolaalpinizmu.pl/turystyka/turystyka-zimowa-iist/'
      when :skitour_1
        'https://szkolaalpinizmu.pl/narty/kursy-skiturowe/kurs-skiturowy-i-stopnia/'
      when :skitour_2
        'https://szkolaalpinizmu.pl/narty/kursy-skiturowe/kurs-skiturowy-ii-stopnia/'
      when :skitour_3
        'https://szkolaalpinizmu.pl/narty/kursy-skiturowe/kurs-narciarstwa-wysokogorskiego/'
      when :skitour_avalanche
        'https://szkolaalpinizmu.pl/narty/kurs-skiturowo-lawinowy'
      when :skitour_avalanche_2
        'https://szkolaalpinizmu.pl/narty/kursy-skiturowe/kurs-skiturowo-lawinowy-ii-stopnia/'
      when :climbing_1
        'https://szkolaalpinizmu.pl/wspinanie/wspinaczka-skalna/drogi-ubezpieczone/'
      when :climbing_2
        'https://szkolaalpinizmu.pl/wspinanie/wspinaczka-skalna/kurs-na-wlasnej/'
      when :full_climbing
        'https://szkolaalpinizmu.pl/wspinanie/wspinaczka-skalna/pelny-kurs-wspinaczki/'
      when :club_climbing
        'https://szkolaalpinizmu.pl/wspinanie/wspinaczka-skalna/klubowy-kurs-wspinaczki/'
      when :summer_tatra
        'https://szkolaalpinizmu.pl/wspinanie/taternictwo/kurs-taternicki-letni/'
      when :winter_tatra_1
        'https://szkolaalpinizmu.pl/wspinanie/taternictwo/zimowy-i-stopnia/'
      when :winter_tatra_2
        'https://szkolaalpinizmu.pl/wspinanie/taternictwo/zimowy-ii-stopnia/'
      when :ice_1
        'https://szkolaalpinizmu.pl/wspinanie/wspinaczka-lodowa/'
      when :ice_2
        'https://szkolaalpinizmu.pl/wspinanie/wspinaczka-lodowa/'
      when :cave
        'https://szkolaalpinizmu.pl/jaskinie/'
      else
        'https://szkolaalpinizmu.pl/o-nas/klub-i-szkola/'
      end
    end

    def logo
      case activity_type.to_sym
      when :winter_abc, :winter_tourist_1, :winter_tourist_2
        'https://panel.kw.krakow.pl/assets/kw-7b39344ecee6060042f85c3875d827e54a32ff867bf12eb62de751249dd20d0c.png'
      when :skitour_1, :skitour_2, :skitour_3, :skitour_avalanche, :skitour_avalanche_2
        'https://panel.kw.krakow.pl/assets/snw-be2731e417162f8a0868bf081d1971362c768773f10840bdf6d74d9154b4fd4b.png'
      when :climbing_1, :climbing_2, :full_climbing, :summer_tatra, :club_climbing
        'https://panel.kw.krakow.pl/assets/sww-4cc5e8fb1b78b03696ab49766a499fb36ecfe698641ec3e3a22d3f1f821184ed.png'
      when :winter_tatra_1, :winter_tatra_2, :ice_1, :ice_2
        'https://panel.kw.krakow.pl/assets/sww-4cc5e8fb1b78b03696ab49766a499fb36ecfe698641ec3e3a22d3f1f821184ed.png'
      when :cave
        'https://panel.kw.krakow.pl/assets/stj-da6e5b49b22498ae143dfaaf7327744543424caef65ce41e1d0c38c5bef1059d.png'
      else
        'https://panel.kw.krakow.pl/assets/kw-7b39344ecee6060042f85c3875d827e54a32ff867bf12eb62de751249dd20d0c.png'
      end
    end

    def as_json(options={})
      super.merge(
        activity_url: activity_url,
        logo: logo,
        display_name: I18n.t("activerecord.attributes.#{model_name.i18n_key}.activity_types.#{activity_type}"),
        free_seats: max_seats ? max_seats - seats : 0
      )
    end
  end
end
