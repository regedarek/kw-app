module Activities
  class CompetitionsTable
    include ActionView::Helpers::AssetTagHelper
    include Rails.application.routes.url_helpers
    ApplicationController.append_view_path Rails.root.join('app', 'components', 'activities')

    def country_iso(country)
      case country.to_sym
      when :poland
        :pl
      when :slovakia
        :sk
      when :italy
        :it
      when :france
        :fr
      when :austria
        :at
      when :czech
        :cz
      when :deutchland
        :de
      when :switzerland
        :ch
      when :andorra
        :ar
      when :china
        :cn
      else
        :en
      end
    end

    def table_months
      [12, 01, 02, 03, 04]
    end

    def table_days
      1..31
    end

    def table_from_year
      2019
    end

    def table_to_year
      2020
    end

    def month_days(table_month)
      days = if table_month == 12
        Time.days_in_month(table_month, table_from_year)
      else
        Time.days_in_month(table_month, table_to_year)
      end
      1..days
    end

    def month_has_day?(table_month, table_day)
      days = if table_month == 12
        Time.days_in_month(table_month, table_from_year)
      else
        Time.days_in_month(table_month, table_to_year)
      end
      table_day <= days
    end

    def competitions_for(table_month, table_day, country, series)
      date = if table_month == 12
        Date.new(table_from_year, table_month, table_day)
      else
        Date.new(table_to_year, table_month, table_day)
      end

      if country && country.present?
        Activities::CompetitionRecord.where(country: country).where('start_date <= ? AND end_date >= ?', date, date)
      elsif series && series.present?
        Activities::CompetitionRecord.where(series: series).where('start_date <= ? AND end_date >= ?', date, date)
      else
        Activities::CompetitionRecord.where('start_date <= ? AND end_date >= ?', date, date)
      end
    end

    def is_weekend?(table_month, table_day)
      date = if table_month == 12
        Date.new(table_from_year, table_month, table_day)
      else
        Date.new(table_to_year, table_month, table_day)
      end

      date.saturday? || date.sunday?
    end
  end
end
