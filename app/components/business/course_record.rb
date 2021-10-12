module Business
  class CourseRecord < ActiveRecord::Base
    include Workflow
    include ActionView::Helpers::AssetTagHelper
    extend FriendlyId
    self.table_name = 'business_courses'
    has_paper_trail

    belongs_to :course_type, class_name: '::Business::CourseTypeRecord'

    has_many :sign_ups, class_name: 'Business::SignUpRecord', foreign_key: :course_id, dependent: :destroy
    has_many :comments, as: :commentable, class_name: 'Messaging::CommentRecord'
    belongs_to :instructor, class_name: '::Settlement::ContractorRecord', foreign_key: :instructor_id
    belongs_to :coordinator, class_name: '::Db::User', foreign_key: :coordinator_id
    belongs_to :event, class_name: 'Training::Supplementary::CourseRecord', foreign_key: :event_id, dependent: :destroy

    has_many :list_courses, class_name: 'Business::ListCourseRecord', foreign_key: :course_id
    has_many :lists, through: :list_courses, dependent: :destroy, foreign_key: :list_id

    has_many :course_conversations, class_name: '::Business::CourseConversationRecord', :dependent => :destroy, foreign_key: :course_id
    has_many :conversations, :through => :course_conversations, :dependent => :destroy, foreign_key: :conversation_id

    has_many :project_items, as: :accountable, class_name: '::Settlement::ProjectItemRecord', :dependent => :destroy
    has_many :projects, :through => :project_items, :dependent => :destroy

    has_many :conversation_items, as: :messageable, class_name: '::Messaging::ConversationItemRecord', :dependent => :destroy
    has_many :conversations, :through => :conversation_items, :dependent => :destroy

    has_many :package_types,
      class_name: 'Business::PackageTypeRecord',
      dependent: :destroy,
      foreign_key: :business_course_record_id

    validates :seats, numericality: { greater_than_or_equal_to: 0, message: 'Minimum to 0' }
    validates :start_date, :max_seats, presence: true
    validates :price, :description, :payment_first_cost, :payment_second_cost, presence: true
    validates :course_type, presence: true
    validate :max_seats_size

    friendly_id :slug_candidates, use: :slugged

    accepts_nested_attributes_for :package_types,
      reject_if: proc { |attributes| attributes[:name].blank? },
      allow_destroy: true

    def income_sum
      prepaid_sign_ups.inject(0) do |sum, sign_up|
        sum = sum + sign_up.first_payment.amount if sign_up.first_payment && sign_up.first_payment.paid?
        sum = sum + sign_up.second_payment.amount if sign_up.second_payment && sign_up.second_payment.paid?
        sum
      end
    end

    def prepaid_sign_ups
      sign_ups
        .includes(:payments)
        .where(payments: { state: 'prepaid' })
    end

    def sign_ups_versions
      PaperTrail::Version.includes(:item).where(item_type: 'Business::SignUpRecord', item_id: sign_ups)
    end

    def sign_ups_payments_versions
      payment_ids = sign_ups.map(&:payment_ids).flatten
      PaperTrail::Version.includes(:item).where(item_type: 'Db::Payment', item_id: payment_ids)
    end

    def lists_versions
      sign_up_ids = sign_ups.includes(:list).map(&:list)
      PaperTrail::Version.includes(:item).where(item_type: 'Business::ListRecord', item_id: sign_up_ids)
    end

    def all_versions
      PaperTrail::Version
        .includes(:item)
        .where(item_type: 'Business::SignUpRecord', item_id: sign_ups)
        .or(
          PaperTrail::Version
            .includes(:item)
            .where(item_type: 'Business::CourseRecord', item_id: self.id)
        )
        .or(sign_ups_payments_versions)
        .or(lists_versions)
        .order(created_at: :asc)
    end

    def name
      return course_type.name if course_type
    end

    def sign_ups_count
      if event_id
        Training::Supplementary::Limiter.new(event).sum
      else
        seats
      end
    end

    def event_url
      if event_id
        "/wydarzenia/#{event.slug}"
      else
        sign_up_url
      end
    end

    def start_date
      starts_at&.to_date
    end

    def end_date
      ends_at&.to_date
    end

    def slug_candidates
      [
        [:start_date, :name]
      ]
    end

    def conversation
      conversations.first
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

    def activity_url
      course_type.sign_ups_uri
    end

    def activity_type
      course_type.type_sym
    end

    def payment_type
      :trainings
    end

    def period
      "#{start_date.strftime("%d/%m/%Y")} - #{end_date.strftime("%d/%m/%Y")}"
    end

    def name_with_date
      "#{start_date} #{name}"
    end

    def logo
      return "kw.png" unless course_type

      return course_type.logo_uri if course_type
    end

    def cost
      price
    end

    def as_json(options={})
      super.merge(
        activity_url: activity_url,
        activity_type: activity_type,
        logo: logo,
        display_name: name,
        instructor_name: instructor ? instructor.display_name : "",
        free_seats: max_seats ? max_seats - sign_ups_count : 0,
        sign_up_url: event_url
      )
    end
  end
end
