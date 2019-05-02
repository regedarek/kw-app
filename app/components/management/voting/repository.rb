module Management
  module Voting
    class Repository
      def management_users
        Db::User.where('roles @> ARRAY[?]', 'management')
      end

      def already_voted_on(case_id)
        case_record = Management::Voting::CaseRecord.find(case_id)

        case_record.votes.includes(:user)
      end

      def missing_votes_on(case_id)
        case_record = Management::Voting::CaseRecord.find(case_id)

        management_users - case_record.users
      end

      def voting_results(case_id)
        approved = already_voted_on(case_id).where(approved: true)
        unapproved = already_voted_on(case_id).where(approved: false)

        "#{approved.count} /\ #{unapproved.count} /\ #{already_voted_on(case_id).count}"
      end

      def approved?(case_id)
        approved = already_voted_on(case_id).where(approved: true)
        unapproved = already_voted_on(case_id).where(approved: false)

        return false if already_voted_on(case_id).count <= management_users.count / 2
        approved.count > unapproved.count
      end
    end
  end
end
