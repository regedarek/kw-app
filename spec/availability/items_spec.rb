# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Availability::Items do
  let(:start_date) { '2016-08-25' }
  
  before { Timecop.freeze('2016-08-14'.to_date) }
  after { Timecop.return }
  
  # Create items with different owners
  let!(:item_kw_1) { create(:item, :kw_owned, rentable: true) }
  let!(:item_kw_2) { create(:item, :kw_owned, rentable: true) }
  let!(:item_snw) { create(:item, :snw_owned, rentable: true) }
  let!(:item_not_rentable) { create(:item, :sww_owned, rentable: false) }
  let!(:item_instructors) { create(:item, :instructors_owned, rentable: true) }
  let!(:item_sww) { create(:item, :sww_owned, rentable: true) }
  
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }
  
  before do
    # Reserve some items for the start_date
    reservation1 = create(:reservation,
      user: user1,
      start_date: start_date,
      end_date: start_date.to_date + 7
    )
    reservation1.items << item_kw_1
    reservation1.items << item_kw_2
    
    reservation2 = create(:reservation,
      user: user2,
      start_date: start_date,
      end_date: start_date.to_date + 7
    )
    reservation2.items << item_sww
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
    # Should only return item_snw (rentable, snw owned, not reserved)
    # Excludes: item_kw_1 & item_kw_2 (reserved), item_not_rentable (not rentable),
    # item_instructors (instructors owned), item_sww (reserved)
    expect(subject).to match_array([item_snw])
  end
end