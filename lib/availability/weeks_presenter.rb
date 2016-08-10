# (Date.today..20.weeks.from_now).select(&:thursday?).map{|date| ["#{date}..#{(date.end_of_week(:thursday) + 1)}", date]}
module Availability
  class WeeksPresenter
    def self.to_options
        (Date.today..Date.today + 4.months).step(30).map do |month_date|
          [
            I18n.l(month_date, format: "%B %Y"),
            (month_date.beginning_of_month..month_date.end_of_month)
              .select(&:thursday?)
              .map { |date| ["od czwartku #{I18n.l(date, format: "%d")} do czwartku #{I18n.l(date.end_of_week(:thursday) + 1, format: "%d")}", date.to_s] }
          ]
        end
    end
  end
end
