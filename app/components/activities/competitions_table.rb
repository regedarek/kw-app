module Activities
  class CompetitionsTable
    include ActionView::Helpers::AssetTagHelper
    include Rails.application.routes.url_helpers
    ApplicationController.append_view_path Rails.root.join('app', 'components', 'activities')

    def call
      ApplicationController.render(partial: "api/competitions/table", locals: { competitions: competitions }, cached: true)
    end

    def table_months
      [12, 01, 02, 03, 04]
    end

    def table_days
      1..31
    end

    def competitions
      Activities::CompetitionRecord.all
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

    def competitions_for(table_month, table_day)
      date = if table_month == 12
        Date.new(table_from_year, table_month, table_day)
      else
        Date.new(table_to_year, table_month, table_day)
      end

      Activities::CompetitionRecord.where('start_date <= ? AND end_date >= ?', date, date)
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
