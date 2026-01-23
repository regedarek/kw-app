# == Schema Information
#
# Table name: supplementary_courses
#
#  id                   :integer          not null, primary key
#  accepted             :boolean          default(FALSE)
#  active               :boolean          default(FALSE), not null
#  application_date     :datetime
#  baner                :string
#  baner_type           :integer          default("baner_mountain_climbing"), not null
#  cash                 :boolean          default(FALSE), not null
#  category             :integer          default("kw"), not null
#  conversation_at      :datetime
#  email                :string
#  email_remarks        :text
#  end_application_date :datetime
#  end_date             :datetime
#  expired_hours        :integer          default(0), not null
#  kind                 :integer          default("other"), not null
#  last_fee_paid        :boolean          default(FALSE), not null
#  limit                :integer          default(0), not null
#  name                 :string
#  one_day              :boolean          default(TRUE), not null
#  open                 :boolean          default(TRUE), not null
#  packages             :boolean          default(FALSE)
#  paid_email           :text
#  participants         :text             default([]), is an Array
#  payment_type         :integer          default("trainings"), not null
#  place                :string
#  price                :boolean          default(FALSE), not null
#  price_kw             :integer
#  price_non_kw         :integer
#  question             :boolean          default(FALSE), not null
#  remarks              :text
#  reserve_list         :boolean          default(FALSE), not null
#  send_manually        :boolean          default(FALSE), not null
#  slug                 :string           not null
#  start_date           :datetime
#  state                :integer          default("draft"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  organizator_id       :integer
#
# Indexes
#
#  index_supplementary_courses_on_slug  (slug) UNIQUE
#
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

      has_many :project_items, as: :accountable, class_name: '::Settlement::ProjectItemRecord', :dependent => :destroy
      has_many :projects, through: :project_items

      has_many :contract_events, class_name: 'Settlement::ContractEventsRecord', foreign_key: :event_id
      has_many :contracts, through: :contract_events, foreign_key: :contract_id, dependent: :destroy
      belongs_to :organizer, class_name: 'Db::User', foreign_key: :organizator_id, optional: true

      scope :upcoming, lambda { where("start_date >= ?", Date.today).order("start_date") }

      accepts_nested_attributes_for :package_types,
        reject_if: proc { |attributes| attributes[:name].blank? },
        allow_destroy: true

      self.table_name = 'supplementary_courses'

      def name_with_date
        "#{start_date&.to_date} #{name}"
      end

      def income_sum
        prepaid_sign_ups.inject(0) { |sum, s| sum + s.cost }
      end

      def prepaid_sign_ups
        sign_ups
          .includes(:course, :payment)
          .where(payments: { state: 'prepaid' })
      end

      def original_conversation
        return nil unless conversations.any?
        conversations.order(:created_at).first
      end

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
