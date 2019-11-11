module Scrappers
  class Topr
    def call
      page = Nokogiri::HTML(open('http://lawiny.topr.pl'))
      statement = page.xpath('/html/body/div[1]/div[2]/div[1]/section[2]/div[1]/div[1]/div/div[2]').text.squish

      Scrappers::ToprRecord.create(
        time: Time.now,
        remote_topr_pdf_url: 'http://lawiny.topr.pl/viewpdf'
      )
    end
  end
end
