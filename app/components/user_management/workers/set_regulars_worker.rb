module UserManagement
  module Workers
    class SetRegularsWorker
      include Sidekiq::Worker

      def perform(**)
        Db::Profile.ransack(position_not_cont: 'regular', application_date_lteq: 1.year.ago).result.find_each do |p|
          p.position.push('regular').uniq
          p.position.delete('candidate')
          p.save
        end
      end
    end
  end
end
