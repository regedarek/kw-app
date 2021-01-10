module Membership
  module Workers
    class DestroyOudatedProfilesWorker
      include Sidekiq::Worker

      def perform(**)
        outdated_profiles = Membership::FeesRepository.new.find_outdated_not_prepaided_profiles
        outdated_profiles.map(&:destroy)
      end
    end
  end
end
