module UserManagement
  class RecalculateCost
    def all
      Db::Profile.includes(:payment).where(accepted: false, payments: { state: 'unpaid' }).each do |profile|
        ::UserManagement::Workers::ProfileRecalculateCostWorker.perform_async(profile.id)
      end
    end
  end
end
