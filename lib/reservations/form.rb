require 'form_object'

module Reservations
  class Form < FormObject
    attribute :start_date, String
    attribute :end_date, String
    attribute :item_ids, Array

    validates :item_ids, :start_date, :end_date, presence: true
    validate :start_date_is_not_thursday, :end_date_is_not_thursday
    validate :start_date_is_in_the_past, :end_date_is_in_the_past
    validate :end_date_is_before_start_date
    validate :end_date_is_not_one_week_later

    def start_date
      @start_date.to_date
    end

    def end_date
      @end_date.to_date
    end

    def items
      Db::Item.where(id: item_ids)
    end

    def start_date_is_not_thursday
      unless start_date.thursday?
        errors.add(:start_date, "has to be thursday")
      end
    end

    def end_date_is_not_thursday
      unless end_date.thursday?
        errors.add(:end_date, "has to be thursday")
      end
    end

    def start_date_is_in_the_past
      unless Time.zone.now < start_date
        errors.add(:start_date, "cannot be in the past")
      end
    end

    def end_date_is_in_the_past
      unless Time.zone.now < end_date
        errors.add(:end_date, "cannot be in the past")
      end
    end

    def end_date_is_before_start_date
      unless start_date < end_date
        errors.add(:end_date, "cannot be before start_date")
      end
    end

    def end_date_is_not_one_week_later
      unless end_date == start_date.next_week(:thursday)
        errors.add(:end_date, "has to be one week later")
      end
    end
  end
end
