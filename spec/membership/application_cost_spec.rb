require 'rails_helper'

describe UserManagement::ApplicationCost do
  after { Timecop.return }

  describe '.for' do
    context 'no profile' do
      it do
        result = UserManagement::ApplicationCost.for(profile: nil)
        expect(result.not_found?).to eq(true)
      end
    end

    context 'months 1-8' do
      before { Timecop.freeze('2016-06-19'.to_date) }
      it 'other' do
        profile = Factories::Profile.build_form
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(50)
        expect(result.year_fee).to eq(100)
      end
    end

    context 'months 9-11' do
      before { Timecop.freeze('2016-10-19'.to_date) }
      it 'other' do
        profile = Factories::Profile.build_form
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(50)
        expect(result.year_fee).to eq(50)
      end
    end

    context 'months 11-12' do
      before { Timecop.freeze('2016-11-19'.to_date) }
      it 'other' do
        profile = Factories::Profile.build_form
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(50)
        expect(result.year_fee).to eq(100)
      end
    end

    context 'months 1-8' do
      before { Timecop.freeze('2016-06-19'.to_date) }
      it 'other club' do
        profile = Factories::Profile.build_form(acomplished_courses: ['basic', 'other_club'])
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(0)
        expect(result.year_fee).to eq(100)
      end
    end

    context 'months 9-11' do
      before { Timecop.freeze('2016-10-19'.to_date) }
      it 'other club' do
        profile = Factories::Profile.build_form(acomplished_courses: ['basic', 'other_club'])
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(0)
        expect(result.year_fee).to eq(50)
      end
    end

    context 'months 11-12' do
      before { Timecop.freeze('2016-11-19'.to_date) }
      it 'other club' do
        profile = Factories::Profile.build_form(acomplished_courses: ['basic', 'other_club'])
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(0)
        expect(result.year_fee).to eq(100)
      end
    end

    context 'months 1-8' do
      before { Timecop.freeze('2016-06-19'.to_date) }
      it 'reactivation' do
        profile = Factories::Profile.build_form
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(50)
        expect(result.year_fee).to eq(100)
      end
    end

    context 'months 9-11' do
      before { Timecop.freeze('2016-10-19'.to_date) }
      it 'reactivation' do
        profile = Factories::Profile.build_form
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(50)
        expect(result.year_fee).to eq(50)
      end
    end

    context 'months 11-12' do
      before { Timecop.freeze('2016-11-19'.to_date) }
      it 'reactivation' do
        profile = Factories::Profile.build_form
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(50)
        expect(result.year_fee).to eq(100)
      end
    end

    context 'months 1-8' do
      before { Timecop.freeze('2016-06-19'.to_date) }
      it 'internal basic' do
        profile = Factories::Profile.build_form(acomplished_courses: ['basic_kw'])
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(50)
        expect(result.year_fee).to eq(0)
      end
    end

    context 'months 9-11' do
      before { Timecop.freeze('2016-10-19'.to_date) }
      it 'internal basic' do
        profile = Factories::Profile.build_form(acomplished_courses: ['basic_kw'])
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(50)
        expect(result.year_fee).to eq(0)
      end
    end

    context 'months 11-12' do
      before { Timecop.freeze('2016-11-19'.to_date) }
      it 'internal basic' do
        profile = Factories::Profile.build_form(acomplished_courses: ['basic_kw'])
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(50)
        expect(result.year_fee).to eq(0)
      end
    end

    context 'months 1-8' do
      before { Timecop.freeze('2016-06-19'.to_date) }
      it 'external basic' do
        profile = Factories::Profile.build_form(acomplished_courses: ['basic'])
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(50)
        expect(result.year_fee).to eq(100)
      end
    end

    context 'months 9-11' do
      before { Timecop.freeze('2016-10-19'.to_date) }
      it 'external basic' do
        profile = Factories::Profile.build_form(acomplished_courses: ['basic'])
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(50)
        expect(result.year_fee).to eq(50)
      end
    end

    context 'months 11-12' do
      before { Timecop.freeze('2016-11-19'.to_date) }
      it 'external basic' do
        profile = Factories::Profile.build_form(acomplished_courses: ['basic'])
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(50)
        expect(result.year_fee).to eq(100)
      end
    end

    context 'months 1-8' do
      before { Timecop.freeze('2016-06-19'.to_date) }
      it 'inctructor' do
        profile = Factories::Profile.build_form(acomplished_courses: ['instructors'])
        result = UserManagement::ApplicationCost.for(profile: profile)
        expect(result.first_fee).to eq(0)
        expect(result.year_fee).to eq(100)
      end
    end

    context 'months 9-11' do
      before { Timecop.freeze('2016-10-19'.to_date) }
      it 'inctructor' do
        profile = Factories::Profile.build_form(acomplished_courses: ['instructors'])
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(0)
        expect(result.year_fee).to eq(50)
      end
    end

    context 'months 11-12' do
      before { Timecop.freeze('2016-11-19'.to_date) }
      it 'inctructor' do
        profile = Factories::Profile.build_form(acomplished_courses: ['instructors'])
        result = UserManagement::ApplicationCost.for(profile: profile)

        expect(result.first_fee).to eq(0)
        expect(result.year_fee).to eq(100)
      end
    end
  end
end
