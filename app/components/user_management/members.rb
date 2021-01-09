require 'net/http'

module UserManagement
  class Members
    def self.set_regular
      Db::Profile.ransack(position_not_cont: 'regular', application_date_lteq: 1.year.ago).result.find_each do |p|
        p.position.push('regular').uniq
        p.position.delete('candidate')
        p.save
      end
    end
  end
end
