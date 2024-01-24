# == Schema Information
#
# Table name: competitions
#
#  id                  :integer          not null, primary key
#  accept_first        :boolean          default(FALSE), not null
#  alert               :text
#  baner               :string
#  close_payment       :datetime
#  closed              :boolean          default(FALSE), not null
#  country_required    :boolean          default(FALSE), not null
#  custom_form         :string
#  edition_sym         :string           not null
#  email_text          :text             not null
#  en_email_text       :text
#  event_date          :datetime
#  license_id_required :boolean          default(FALSE), not null
#  limit               :integer          default(0), not null
#  matrimonial_office  :boolean          default(FALSE), not null
#  medical_rules_text  :text
#  name                :string
#  organizer_email     :string           default("kw@kw.krakow.pl"), not null
#  rules               :string
#  rules_text          :text
#  sign_up_starts_at   :datetime
#  single              :boolean          default(FALSE), not null
#  team_name           :boolean          default(FALSE), not null
#  tshirt_url          :string
#  weekend_nights      :boolean          default(FALSE), not null
#  weekend_nights_text :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
module Events
  module Db
    class CompetitionRecord < ActiveRecord::Base
      mount_uploader :baner, Events::Competitions::BanerUploader
      self.table_name = 'competitions'

      has_many :sign_ups_records,
        class_name: 'Events::Db::SignUpRecord',
        dependent: :destroy
      has_many :package_types,
        class_name: 'Events::Db::CompetitionPackageTypeRecord',
        dependent: :destroy,
        inverse_of: :competition

      accepts_nested_attributes_for :package_types,
        reject_if: proc { |attributes| attributes[:name].blank? },
        allow_destroy: true

      def form
        case custom_form
        when 'mjs'
          ::Events::Competitions::SignUps::MjsForm.new
        else
          ::Events::Competitions::SignUps::SignUpSingleForm.new
        end
      end

      def closed_or_limit_reached?
        closed? || limit_reached?
      end

      def limit_reached?
        Events::Competitions::SignUps::Limiter.new(self).reached?
      end
    end
  end
end
