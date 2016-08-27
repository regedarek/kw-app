require 'rails_helper'

describe Availability::Items do
  let!(:items) { Factories::Item.create_all! }
  let(:start_date) { '2016-08-25' }
  before { Timecop.freeze('2016-08-14'.to_date) }
  after { Timecop.return }
  before do
    Factories::Reservation.create!(
      id: 1,
      user_id: 1,
      item_ids: [1, 2],
      start_date: start_date,
      end_date: start_date.to_date + 7
    )
    Factories::Reservation.create!(
      id: 2,
      user_id: 2,
      item_ids: [6],
      start_date: start_date,
      end_date: start_date.to_date + 7
    )
  end
  subject { described_class.new(start_date: start_date).collect }

  context 'start_date in the past' do
    let(:start_date) { '2016-08-01' }

    it 'returns warning' do
      expect { subject }.to raise_error('start date cannot be in the past')
    end
  end

  context 'start_date is not thursday' do
    let(:start_date) { '2016-09-24' }

    it 'returns warning' do
      expect { subject }.to raise_error('start date has to be thursday')
    end
  end

  it 'excludes not available, instructors and not rentale items' do
    expect(subject).to match_array([Db::Item.find(3)])
  end
end
