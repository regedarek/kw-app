module Db
  module Strzelecki
    class SignUp < ActiveRecord::Base
      PRICES = { junior: 75, kw: 95, standard: 125 }
      self.table_name = "strzelecki_sign_ups"
      enum gender_1: [:male, :female], _suffix: :one
      enum gender_2: [:male, :female], _suffix: :two
      enum package_type_1: [:kw, :junior, :standard], _suffix: :one
      enum package_type_2: [:none, :kw, :junior, :standard], _suffix: :two

      has_one :service, as: :serviceable
      has_one :order, through: :service

      def self.gender_attributes_for_select
        gender_1s.map do |type, _|
          [I18n.t("activerecord.attributes.#{model_name.i18n_key}.gender.#{type}"), type]
        end
      end

      def self.category_types_attributes_for_select
        category_types.map do |type, _|
          [I18n.t("activerecord.attributes.#{model_name.i18n_key}.category_types.#{type}"), type]
        end
      end

      def self.package_type_1_attributes_for_select
        [:kw, :junior, :standard].map do |type|
          [I18n.t("activerecord.attributes.db/strzelecki/sign_up.package_types.#{type}", price: Db::Strzelecki::SignUp::PRICES[type]), type]
        end
      end

      def self.package_type_2_attributes_for_select
        [:none, :kw, :junior, :standard].map do |type|
          [I18n.t("activerecord.attributes.db/strzelecki/sign_up.package_types.#{type}", price: Db::Strzelecki::SignUp::PRICES[type]), type]
        end
      end
    end
  end
end
