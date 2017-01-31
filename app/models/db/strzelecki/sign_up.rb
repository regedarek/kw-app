module Db
  module Strzelecki
    class SignUp < ActiveRecord::Base
      self.table_name = "strzelecki_sign_ups"
      enum category_type: [:mix, :male, :female]
      enum package_type_1: [:kw, :junior, :standard], _suffix: :one
      enum package_type_2: [:none, :kw, :junior, :standard], _suffix: :two

      has_one :service, as: :serviceable
      has_one :order, through: :service

      def self.category_types_attributes_for_select
        category_types.map do |type, _|
          [I18n.t("activerecord.attributes.#{model_name.i18n_key}.category_types.#{type}"), type]
        end
      end

      def self.package_type_1_attributes_for_select
        [:kw, :junior, :standard].map do |type|
          [I18n.t("activerecord.attributes.db/strzelecki/sign_up.package_types.#{type}"), type]
        end
      end

      def self.package_type_2_attributes_for_select
        [:none, :kw, :junior, :standard].map do |type|
          [I18n.t("activerecord.attributes.db/strzelecki/sign_up.package_types.#{type}"), type]
        end
      end
    end
  end
end
