module Management
  module Voting
    class Repository
      def management_users
        Db::User.where('roles @> ARRAY[?]', 'management')
      end

      def already_voted_on(case_id)
        case_record = Management::Voting::CaseRecord.find(case_id)

        case_record.votes
      end

      def missing_votes_on(case_id)
        case_record = Management::Voting::CaseRecord.find(case_id)

        management_users - case_record.users
      end

      def voting_results(case_id)
        approved = already_voted_on(case_id).where(decision: 'approved')
        unapproved = already_voted_on(case_id).where(decision: 'unapproved')

        "#{approved.count} /\ #{unapproved.count} /\ #{already_voted_on(case_id).count}"
      end

      def approved?(case_id)
        case_record = Management::Voting::CaseRecord.find(case_id)
        return true if case_record.hide_votes?

        approved = already_voted_on(case_id).where(decision: 'approved')
        unapproved = already_voted_on(case_id).where(decision: 'unapproved')

        return false if already_voted_on(case_id).count <= management_users.count / 2
        approved.count > unapproved.count
      end

      def voted?(case_id, user_id)
        already_voted_on(case_id).map(&:user_id).include?(user_id)
      end

      def authorized?(user_id)
        Management::Voting::CommissionRecord.includes(:owner).exists?(authorized_id: user_id)
      end

      def commissions(user_id)
        Management::Voting::CommissionRecord.includes(:owner).where(authorized_id: user_id)
      end
    end
  end
end
