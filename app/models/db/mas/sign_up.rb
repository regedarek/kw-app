module Db
  module Mas
    class SignUp < ActiveRecord::Base
      PRICES = { kw: 40, standard: 70 }
      self.table_name = 'mas_sign_ups'
      enum gender_1: [:male, :female], _suffix: :one
      enum gender_2: [:male, :female], _suffix: :two
      enum tshirt_size_1: [:wxs, :ws, :wm, :wl, :wxl, :w2xl, :ms, :mm, :ml, :mxl, :m2xl, :m3xl, :m4xl], _suffix: :one
      enum tshirt_size_2: [:wxs, :ws, :wm, :wl, :wxl, :w2xl, :ms, :mm, :ml, :mxl, :m2xl, :m3xl, :m4xl], _suffix: :two
      enum package_type_1: [:kw, :standard], _suffix: :one
      enum package_type_2: [:kw, :standard], _suffix: :two

      has_one :payment, as: :payable, dependent: :destroy

      def cost
        Db::Mas::SignUp::PRICES[package_type_1.to_sym] + Db::Mas::SignUp::PRICES[package_type_2.to_sym]
      end

      def description
        "Wpisowe nr #{id} na zawody VIII Memoriał Andrzeja Skwirczyńskiego 2017 od #{first_name_1} #{last_name_1} oraz #{first_name_2} #{last_name_2}"
      end

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
        [:standard, :kw].map do |type|
          [I18n.t("activerecord.attributes.db/mas/sign_up.package_types.#{type}", price: Db::Mas::SignUp::PRICES[type]), type]
        end
      end

      def self.package_type_2_attributes_for_select
        [:standard, :kw].map do |type|
          [I18n.t("activerecord.attributes.db/mas/sign_up.package_types.#{type}", price: Db::Mas::SignUp::PRICES[type]), type]
        end
      end

      def self.tshirt_sizes_attributes_for_select
        tshirt_size_1s.map do |type, _|
          [I18n.t("activerecord.attributes.#{model_name.i18n_key}.tshirt_sizes.#{type}"), type]
        end
      end

      def category
        if gender_1 == gender_2
          return gender_1
        else
          return 'mix'
        end
      end
    end
  end
end
