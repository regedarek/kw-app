module Scrappers
  class Topr
    def call
      #page = Nokogiri::HTML(open('http://lawiny.topr.pl'))
      #statement = page.xpath('/html/body/div[1]/div[2]/div[1]/section[2]/div[1]/div[1]/div/div[2]').text.squish

      record = Scrappers::ToprRecord.create(
        time: Time.now,
        remote_topr_pdf_url: 'http://lawiny.topr.pl/viewpdf'
      )
      reader = if Rails.env.production?
        File.open('/home/deploy/kw-app/shared/tmp/topr_pdf.pdf', "wb") do |file|
          file.write record.topr_pdf.file.read
        end

        PDF::Reader.new('/home/deploy/kw-app/shared/tmp/topr_pdf.pdf')
      else
        PDF::Reader.new(record.topr_pdf.path)
      end

      paragraph = ""
      paragraphs = []
      page = reader.pages.first
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
      extractor.page(page)

      pathname = if Rails.env.production?
                   Pathname.new('/home/deploy/kw-app/shared/tmp/1-1-I4.tif')
                 else
                   Pathname.new('tmp/1-1-I4.tif')
                 end

      record.update(
        avalanche_degree: paragraphs.join('').gsub!(/.*?(?=PROGNOZA)/im, "").split[4],
        topr_degree: pathname.open
      )
    end

    private

    def extractor
      Scrappers::PdfImageExtractor.new
    end
  end
end
