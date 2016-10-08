require 'rails_helper'
require 'guards'

describe Guards::Date do
  describe '#nearest_thursday' do
    it 'returns closest thursday' do
      expect(described_class.new(date: '2016-08-22').nearest_thursday).to eq('2016-08-25'.to_date)
      expect(described_class.new(date: '2016-08-23').nearest_thursday).to eq('2016-08-25'.to_date)
      expect(described_class.new(date: '2016-08-24').nearest_thursday).to eq('2016-08-25'.to_date)
      expect(described_class.new(date: '2016-08-25').nearest_thursday).to eq('2016-08-25'.to_date)
      expect(described_class.new(date: '2016-08-26').nearest_thursday).to eq('2016-09-01'.to_date)
      expect(described_class.new(date: '2016-08-27').nearest_thursday).to eq('2016-09-01'.to_date)
      expect(described_class.new(date: '2016-08-28').nearest_thursday).to eq('2016-09-01'.to_date)
      expect(described_class.new(date: '2016-08-29').nearest_thursday).to eq('2016-09-01'.to_date)
    end
  end
end
