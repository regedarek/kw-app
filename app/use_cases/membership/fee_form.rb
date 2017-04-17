require 'form_object'

module Membership
  class FeeForm < FormObject
    attribute :kw_id, :integer
    attribute :year, :string

    validates :year,
      presence: true,
      numericality: { only_integer: true, greater_than_or_equal_to: 2000, less_than_or_equal_to: Date.today.year + 1 }

    validate :year_existance

    def year_existance
      if Db::Membership::Fee.exists?(kw_id: kw_id, year: year)
        errors.add(:year, "już istnieje")
      end
    end
  end
end
