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

      def closed_or_limit_reached?
        closed? || limit_reached?
      end

      def limit_reached?
        Events::Competitions::SignUps::Limiter.new(self).reached?
      end
    end
  end
end
