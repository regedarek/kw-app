module Scrappers
  class Topr
    def call
      page = Nokogiri::HTML(open('http://lawiny.topr.pl'))
      statement = page.xpath('/html/body/div[1]/div[2]/div[1]/section[2]/div[1]/div[1]/div/div[2]').text.squish

      Scrappers::ToprRecord.create(
        time: Date.today,
        statement: statement,
        avalanche_degree: 0
      )

      Net::HTTP.get(URI('https://hc-ping.com/861c60b0-4642-407a-80c3-e629f0ff2c85'))
    end
  end
end
