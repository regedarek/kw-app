module Scrappers
  class Topr
    def call
      page = Nokogiri::HTML(open('http://lawiny.topr.pl'))
      statement = page.xpath('/html/body/div[1]/div[2]/div[1]/section[2]/div[1]/div[1]/div/div[2]').text.squish

      ToprRecord.create(
        time: Date.today,
        statement: statement,
        avalanche_degree: 0
      ) if [12, 01, 02, 03, 04, 05].include?(Date.today.month)
    end
  end
end
