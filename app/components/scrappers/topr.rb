module Scrappers
  class Topr
    def call
      page = Nokogiri::HTML(open('http://lawiny.topr.pl'))
      statement = page.xpath('/html/body/div[1]/div[2]/div[1]/section[2]/div[1]/div[1]/div/div[2]').text.squish

      record = Scrappers::ToprRecord.create(
        time: Time.now,
        remote_topr_pdf_url: 'http://lawiny.topr.pl/viewpdf'
      )
      reader = PDF::Reader.new(record.topr_pdf.path)

      paragraph = ""
      paragraphs = []
      reader.pages.each do |page|
        lines = page.text.scan(/^.+/)
        lines.each do |line|
          if line.length > 55
            paragraph += " #{line}"
          else
            paragraph += " #{line}"
            paragraphs << paragraph
            paragraph = ""
          end
        end
      end

      record.update(
        avalanche_degree: paragraphs[4].gsub!(/.*?(?=PROGNOZA)/im, "").split[1]
      )
    end
  end
end
