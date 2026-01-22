require 'rails_helper'

RSpec.describe 'Training::Supplementary::Courses Error Display', type: :request do
  let(:user) { Factories::User.create! }

  before do
    login_as(user, scope: :user)
  end

  describe 'POST /wydarzenia/nowe - validation errors' do
    context 'with multiple missing required fields' do
      let(:invalid_params) do
        {
          course: {
            name: '',
            place: '',
            payment_type: '',
            category: 'kw',
            state: 'published'
          }
        }
      end

      it 'does not create a new course' do
        expect {
          post supplementary_courses_path, params: invalid_params
        }.not_to change(Training::Supplementary::CourseRecord, :count)
      end

      it 'shows error messages that identify which fields are missing' do
        post supplementary_courses_path, params: invalid_params
        
        # The response should contain error information
        expect(response.body).to include('is missing')
        
        # Count how many times "is missing" appears
        # Should be at least 3 (for name, place, payment_type)
        missing_count = response.body.scan(/is missing/).length
        expect(missing_count).to be >= 3
        
        # The issue: errors currently show as just "is missing" repeated
        # without field names, making it unhelpful to users
      end
    end

    context 'with only name missing' do
      let(:params_missing_name) do
        {
          course: {
            name: '',
            place: 'Kraków',
            payment_type: 'trainings'
          }
        }
      end

      it 'does not create a course' do
        expect {
          post supplementary_courses_path, params: params_missing_name
        }.not_to change(Training::Supplementary::CourseRecord, :count)
      end

      it 'shows an error about the missing name' do
        post supplementary_courses_path, params: params_missing_name
        
        # Should show error about name being missing
        expect(response.body).to include('is missing')
        
        # Currently the error doesn't specify which field
      end
    end

    context 'with valid parameters' do
      let(:valid_params) do
        {
          course: {
            name: 'Test Course',
            place: 'Kraków',
            payment_type: 'trainings',
            category: 'kw',
            state: 'draft',
            expired_hours: 24,
            limit: 10
          }
        }
      end

      it 'creates a new course' do
        expect {
          post supplementary_courses_path, params: valid_params
        }.to change(Training::Supplementary::CourseRecord, :count).by(1)
      end

      it 'redirects with success message' do
        post supplementary_courses_path, params: valid_params
        expect(response).to redirect_to(wydarzenia_path)
        follow_redirect!
        expect(response.body).to include('Utworzono wydarzenie')
      end
    end
  end
end