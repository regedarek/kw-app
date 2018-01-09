require 'net/http'

module UserManagement
  class Members
    def self.set_regular
      Net::HTTP.get(URI('https://hchk.io/83bb1a17-d3ed-4d57-93d5-faa0b8a81021')

      Db::Profile.ransack(position_not_cont: 'regular', application_date_lteq: 1.year.ago).result.find_each do |p|
        p.position.push('regular').uniq
        p.position.delete('candidate')
        p.save
      end
    end
  end
end
