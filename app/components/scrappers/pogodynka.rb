require 'wombat'

module Scrappers
  class Pogodynka
    def call
      Wombat.crawl do
        base_url "http://www.pogodynka.pl"
        path "/gory/pogoda/tatry/"

        some_data css: "div.elemClass .gory_table"
      end
    end
  end
end
