require 'form_object'

module Membership
  class FeeForm < FormObject
    attribute :kw_id, :integer
    attribute :year, :string
    attribute :plastic, :boolean

    validates :year,
      presence: true,
      numericality: { only_integer: true, greater_than_or_equal_to: 2000, less_than_or_equal_to: Date.today.year + 1 }

    validate :year_existance
    validate :plastic_for_2019

    def plastic_for_2019
      if year == '2019' && plastic == true
        errors.add(:plastic, "jest zablokowane dla 2019 roku z powodu zamknięcia zamówienia.")
      end
    end

    def year_existance
      if Db::Membership::Fee.exists?(kw_id: kw_id, year: year)
        errors.add(:year, "już istnieje")
      end
    end
  end
end
