module Business
  class CourseRecord < ActiveRecord::Base
    include Workflow
    extend FriendlyId

    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'
    belongs_to :instructor, class_name: '::Business::InstructorRecord', foreign_key: :instructor_id

    validates :seats, numericality: { greater_than_or_equal_to: 0, message: 'Minimum to 0' }
    validates :max_seats, presence: true
    validates :sign_up_url, presence: true
    validates :activity_type, presence: true
    validate :max_seats_size

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

    def as_json(options={})
      super.merge(free_seats: max_seats ? max_seats - seats : 0)
    end
  end
end
