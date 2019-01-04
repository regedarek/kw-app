require 'rails_helper'

describe Membership::Activement do
  after { Timecop.return }
  let!(:user) { Factories::User.create! }

  describe '#payment_year' do
    context '01-01 - 15-11' do
      before { Timecop.freeze('2016-06-19'.to_date) }

      it do
        result = Membership::Activement.new
        expect(result.payment_year).to eq(2016)
      end
    end

    context '15-11 - 31-12' do
      before { Timecop.freeze('2016-11-19'.to_date) }

      it do
        result = Membership::Activement.new
        expect(result.payment_year).to eq(2017)
      end
    end
  end

  describe '#active?' do
    context 'no user' do
      it do
        result = Membership::Activement.new(user: nil)
        expect(result.active?).to eq(false)
      end
    end

    context 'no membership_fees' do
      before { Timecop.freeze('2016-06-19'.to_date) }

      it do
        result = Membership::Activement.new(user: user)
        expect(result.active?).to eq(false)
      end
    end

    context 'with prev year' do
      before do
        Factories::Membership::Fee.create!(kw_id: user.kw_id, year: 2015)
      end

      context 'this year 01.01 - 15.11' do
        before do
          Timecop.freeze('2016-01-14'.to_date)
        end

        it do
          result = Membership::Activement.new(user: user)
          expect(result.active?).to eq(true)
        end
      end

      context 'this year 04.01 - 31.12' do
        before do
          Timecop.freeze('2016-04-01'.to_date)
        end

        it do
          result = Membership::Activement.new(user: user)
          expect(result.active?).to eq(false)
        end
      end
    end

    context 'with next year' do
      before do
        Factories::Membership::Fee.create!(kw_id: user.kw_id, year: 2017)
      end

      context 'this year 01.01 - 14.11' do
        before do
          Timecop.freeze('2016-06-19'.to_date)
        end

        it do
          result = Membership::Activement.new(user: user)
          expect(result.active?).to eq(false)
        end
      end

      context 'this year 11.15 - 31.12' do
        before do
          Timecop.freeze('2016-12-19'.to_date)
        end

        it do
          result = Membership::Activement.new(user: user)
          expect(result.active?).to eq(true)
        end
      end
    end

    context 'with too old membership_fees' do
      before do
        Timecop.freeze('2016-06-19'.to_date)
        Factories::Membership::Fee.create!(kw_id: user.kw_id, year: 2014)
      end

      it do
        result = Membership::Activement.new(user: user)
        expect(result.active?).to eq(false)
      end
    end

    context 'with too futher membership_fees' do
      before do
        Timecop.freeze('2016-06-19'.to_date)
        Factories::Membership::Fee.create!(kw_id: user.kw_id, year: 2018)
      end

      it do
        result = Membership::Activement.new(user: user)
        expect(result.active?).to eq(false)
      end
    end

    context 'with only current year fee prepaid' do
      before do
        Factories::Membership::Fee.create!(
          kw_id: user.kw_id,
          year: 2016,
          cash: false,
          state: 'prepaid'
        )
      end

      context '14.11.prev and later' do
        before do
          Timecop.freeze('2015-11-14'.to_date)
        end

        it do
          result = Membership::Activement.new(user: user)
          expect(result.active?).to eq(false)
        end
      end

      context '15.11.prev - 31.12' do
        before do
          Timecop.freeze('2015-11-16'.to_date)
        end

        it do
          result = Membership::Activement.new(user: user)
          expect(result.active?).to eq(true)
        end
      end

      context '01.01 - 15.01' do
        before do
          Timecop.freeze('2016-01-02'.to_date)
        end

        it do
          result = Membership::Activement.new(user: user)
          expect(result.active?).to eq(true)
        end
      end

      context '15.01 - 15.11' do
        before do
          Timecop.freeze('2016-02-19'.to_date)
        end

        it do
          result = Membership::Activement.new(user: user)
          expect(result.active?).to eq(true)
        end
      end

      context '15.11 - 31.12' do
        before do
          Timecop.freeze('2016-12-19'.to_date)
        end

        it do
          result = Membership::Activement.new(user: user)
          expect(result.active?).to eq(true)
        end
      end

      context '01.01.next - 31.03.next' do
        before do
          Timecop.freeze('2017-03-30'.to_date)
        end

        it do
          result = Membership::Activement.new(user: user)
          expect(result.active?).to eq(true)
        end
      end

      context '01.04.next and futher' do
        before do
          Timecop.freeze('2017-04-01'.to_date)
        end

        it do
          result = Membership::Activement.new(user: user)
          expect(result.active?).to eq(false)
        end
      end
    end

    context 'dotpay unpaid for this year' do
      before do
        Timecop.freeze('2016-01-16'.to_date)
        Factories::Membership::Fee.create!(
          kw_id: user.kw_id,
          year: 2016,
          cash: false,
          state: 'unpaid'
        )
      end

      it do
        result = Membership::Activement.new(user: user)
        expect(result.active?).to eq(false)
      end
    end

    context 'cash prepaid for this year' do
      before do
        Timecop.freeze('2016-01-16'.to_date)
        Factories::Membership::Fee.create!(
          kw_id: user.kw_id,
          year: 2016,
          cash: true,
          state: 'unpaid'
        )
      end

      it do
        result = Membership::Activement.new(user: user)
        expect(result.active?).to eq(true)
      end
    end

    context 'cash unpaid for this year' do
      before do
        Timecop.freeze('2016-01-16'.to_date)
        Factories::Membership::Fee.create!(
          kw_id: user.kw_id,
          year: 2016,
          cash: false,
          state: 'unpaid'
        )
      end

      it do
        result = Membership::Activement.new(user: user)
        expect(result.active?).to eq(false)
      end
    end
  end
end
