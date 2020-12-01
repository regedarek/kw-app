module Blog
  class Dashboard
    def fetch
      {
        latest_degree: Scrappers::ToprRecord.last.topr_degree.url(:dashboard),
        total_meters: routes.sum(:length),
        last_route: { name: routes.last.name, date: routes.last.climbing_date },
        max_meters_person: { name: Db::User.find_by(kw_id: best_person.kw_id).display_name, meters: best_person.total_mountain_routes_length }
      }.to_json
    end

    private

    def latest_degree
      today_infos = Scrappers::ToprRecord.where(time: Date.today).order(time: :desc)

      if today_infos.any?
        today_infos.first.topr_degree.url(:dashboard)
      else
        'brak zagrożenia'
      end
    end

    def routes
      Db::Activities::MountainRoute.where(route_type: 'ski').order(:climbing_date)
    end

    def best_person
      Activities::SkiRepository.new.fetch_season.first
    end
  end
end
