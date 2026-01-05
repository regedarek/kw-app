require 'rails_helper'
require 'result'
require 'failure'
require 'success'

RSpec.describe Training::Supplementary::CreateSignUp do
  let(:repository) { Training::Supplementary::Repository.new }
  let(:form) { Training::Supplementary::CreateSignUpForm.new }
  let(:service) { described_class.new(repository, form) }

  describe '#call' do
    context 'when form validation fails' do
      it 'returns Failure with validation errors when required fields are missing' do
        raw_inputs = {
          course_id: '',
          email: '',
          name: ''
        }

        result = service.call(raw_inputs: raw_inputs)

        expect(result).to be_failure
        
        # The result should return validation errors as a hash
        result.invalid do |errors:|
          expect(errors).to be_a(Hash)
          expect(errors.keys).to include(:name, :email, :course_id)
          expect(errors[:name]).to include('must be filled')
          expect(errors[:email]).to include('must be filled')
          expect(errors[:course_id]).to include('must be filled')
        end
      end

      it 'returns Failure with validation errors when fields are blank' do
        raw_inputs = {
          course_id: '',
          email: '',
          name: '',
          question: ''
        }

        result = service.call(raw_inputs: raw_inputs)

        expect(result).to be_failure
        
        result.invalid do |errors:|
          expect(errors).to be_a(Hash)
          expect(errors).not_to be_empty
        end
      end
    end

    # Note: Additional tests for successful sign-up creation would require
    # proper database setup and course records, which is beyond the scope
    # of this validation error fix
  end
end