module Db
  module Strzelecki
    class SignUp < ActiveRecord::Base
      self.table_name = "strzelecki_sign_ups"
      enum category_type: [:mix, :male, :female]
      enum package_type: [:kw, :junior, :standard]

      has_one :service, as: :serviceable
      has_one :order, through: :service

      def self.category_types_attributes_for_select
        category_types.map do |type, _|
          [I18n.t("activerecord.attributes.#{model_name.i18n_key}.category_types.#{type}"), type]
        end
      end

      def self.package_types_attributes_for_select
        package_types.map do |type, _|
          [I18n.t("activerecord.attributes.#{model_name.i18n_key}.package_types.#{type}"), type]
        end
      end
    end
  end
end
