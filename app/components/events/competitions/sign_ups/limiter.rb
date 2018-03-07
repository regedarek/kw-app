module Events
  module Competitions
    module SignUps
      class Limiter
        def initialize(competition)
          @competition = competition
        end

        def limit
          @competition.limit
        end

        def persons
          singles.count + teams_from_singles.count + teams.count * 2
        end

        def singles
          @competition
            .sign_ups_records
            .includes(:payment)
            .where(
              single: true,
              teammate_id: nil,
              payments: { state: 'prepaid' }
            )
        end

        def teams_from_singles
          @competition
            .sign_ups_records
            .includes(:payment)
            .where(
              single: true,
              payments: { state: 'prepaid' }
            ).where.not(teammate_id: nil)
        end

        def teams
          @competition
            .sign_ups_records
            .includes(:payment)
            .where(single: false, payments: { state: 'prepaid' })
        end

        def waiting
          @competition
            .sign_ups_records
            .includes(:payment)
            .where(payments: { state: 'unpaid' })
        end

        def reached?
          return false if limit == 0

          persons >= limit
        end
      end
    end
  end
end
