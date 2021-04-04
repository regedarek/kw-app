module Training
  module Supplementary
    class CourseRecord < ActiveRecord::Base
      extend FriendlyId
      has_paper_trail
      friendly_id :slug_candidates, use: :slugged
      mount_uploader :baner, Training::Supplementary::BanerUploader
      enum category: [:kw, :snw, :sww, :stj, :web]
      enum kind: [:other, :slides, :meeting, :competitions, :tour, :training]
      enum state: [:draft, :published, :cancelled, :archived]
      enum payment_type: [:trainings, :club_trips]
      enum baner_type: [:baner_mountain_climbing, :baner_ice_axes, :baner_party, :baner_ski_route, :baner_ski, :baner_winter_training]

      has_many :sign_ups, class_name: 'Training::Supplementary::SignUpRecord', foreign_key: :course_id
      has_many :package_types,
        class_name: 'Training::Supplementary::PackageTypeRecord',
        dependent: :destroy,
        foreign_key: :supplementary_course_record_id

      has_many :conversation_items, as: :messageable, class_name: '::Messaging::ConversationItemRecord', :dependent => :destroy
      has_many :conversations, :through => :conversation_items, :dependent => :destroy

      has_many :contract_events, class_name: 'Settlement::ContractEventsRecord', foreign_key: :event_id
      has_many :contracts, through: :contract_events, foreign_key: :contract_id, dependent: :destroy
      belongs_to :organizer, class_name: 'Db::User', foreign_key: :organizator_id

      scope :upcoming, lambda { where("start_date >= ?", Date.today).order("start_date") }

      accepts_nested_attributes_for :package_types,
        reject_if: proc { |attributes| attributes[:name].blank? },
        allow_destroy: true

      self.table_name = 'supplementary_courses'

      def slug_candidates
        [
          [:name],
          [:name, :id]
        ]
      end

      def states
        Training::Supplementary::CourseRecord.states.keys.map do |key,value|
          [
            I18n.t("training.supplementary.course.enums.states.#{key}").humanize,
            key.to_sym
          ]
        end
      end

      def payment_types
        Training::Supplementary::CourseRecord.payment_types.keys.map do |key,value|
          [
            I18n.t("training.supplementary.course.enums.payment_types.#{key}").humanize,
            key.to_sym
          ]
        end
      end

      def baner_types
        Training::Supplementary::CourseRecord.baner_types.keys.map do |key,value|
          [
            I18n.t("training.supplementary.course.enums.baner_types.#{key}").humanize,
            key.to_sym
          ]
        end
      end

      def kinds
        Training::Supplementary::CourseRecord.kinds.keys.map do |key,value|
          [
            I18n.t("training.supplementary.course.enums.kinds.#{key}").humanize,
            key.to_sym
          ]
        end
      end

      def categories
        Training::Supplementary::CourseRecord.categories.keys.map do |key,value|
          [
            I18n.t("training.supplementary.course.enums.categories.#{key}").humanize,
            key.to_sym
          ]
        end
      end
    end
  end
end
