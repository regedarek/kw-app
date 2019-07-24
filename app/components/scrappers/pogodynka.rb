module Scrappers
  class Pogodynka
    def call
      page = Nokogiri::HTML(open('http://www.pogodynka.pl/gory/pogoda/tatry/'))
      rows = page.xpath('//table[@class="gory_table"]/tbody/tr')

      rows.collect do |row|
        detail = {}
        [
          [:place, 'td[1]/text()'],
          [:temp, 'td[3]/text()'],
          [:all_snow, 'td[4]/text()'],
          [:daily_snow, 'td[5]/text()'],
          [:snow_type, 'td[6]/text()']
        ].each do |name, xpath|
          detail[name] = row.at_xpath(xpath).to_s.strip
        end
        detail
      end.map { |r| Scrappers::Weather.new(r) }
    end
  end
end
