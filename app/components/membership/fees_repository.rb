module Membership
  class FeesRepository
    def find_unpaid_this_year_by_emails(emails)
      Db::Profile.where(email: emails).select { |p| !paid_this_year.map(&:kw_id).include?(p.kw_id) }.map(&:kw_id)
    end

    def find_paid_two_years_ago
      Db::Membership::Fee
        .includes(:payment)
        .where(
          year: 2.years.ago.year,
          payments: { state: :prepaid }
        )
    end

    def find_paid_one_year_ago
      Db::Membership::Fee
        .includes(:payment)
        .where(
          year: 1.year.ago.year,
          payments: { state: :prepaid }
        )
    end

    def paid_this_year
      Db::Membership::Fee
        .includes(:payment)
        .where(
          year: Date.today.year,
          payments: { state: :prepaid }
        )
    end

    def get_unpaid_kw_ids_last_year
      find_paid_two_years_ago.map(&:kw_id) - find_paid_one_year_ago.map(&:kw_id)
    end

    def get_unpaid_kw_ids_this_year
      find_paid_two_years_ago.map(&:kw_id).concat(find_paid_one_year_ago.map(&:kw_id)).uniq - paid_this_year.map(&:kw_id)
    end
  end
end
