# frozen_string_literal: true

# Template: Request Spec (Integration Test)
# Location: spec/requests/{{resources}}_spec.rb
#
# Replace:
#   {{Resources}} → PascalCase plural (e.g., Users, BlogPosts)
#   {{Resource}}  → PascalCase singular (e.g., User, BlogPost)
#   {{resources}} → snake_case plural (e.g., users, blog_posts)
#   {{resource}}  → snake_case singular (e.g., user, blog_post)

require 'rails_helper'

RSpec.describe '{{Resources}}', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /{{resources}}' do
    let!(:{{resources}}) { create_list(:{{resource}}, 3) }

    it 'returns success' do
      get {{resources}}_path

      expect(response).to have_http_status(:ok)
    end

    it 'displays {{resources}}' do
      get {{resources}}_path

      {{resources}}.each do |{{resource}}|
        expect(response.body).to include({{resource}}.name)
      end
    end

    context 'when user is not signed in' do
      before { sign_out user }

      it 'redirects to sign in' do
        get {{resources}}_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /{{resources}}/:id' do
    let(:{{resource}}) { create(:{{resource}}) }

    it 'returns success' do
      get {{resource}}_path({{resource}})

      expect(response).to have_http_status(:ok)
    end

    it 'displays {{resource}} details' do
      get {{resource}}_path({{resource}})

      expect(response.body).to include({{resource}}.name)
    end

    context 'when {{resource}} does not exist' do
      it 'returns not found' do
        get {{resource}}_path(id: 99999)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /{{resources}}/new' do
    it 'returns success' do
      get new_{{resource}}_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /{{resources}}' do
    let(:valid_params) do
      {
        {{resource}}: {
          name: 'Test {{Resource}}',
          # Add other required attributes
        }
      }
    end

    let(:invalid_params) do
      {
        {{resource}}: {
          name: '', # Invalid: empty name
        }
      }
    end

    context 'with valid params' do
      it 'creates a {{resource}}' do
        expect {
          post {{resources}}_path, params: valid_params
        }.to change(Db::{{Resource}}, :count).by(1)
      end

      it 'redirects to {{resource}}' do
        post {{resources}}_path, params: valid_params

        expect(response).to redirect_to({{resource}}_path(Db::{{Resource}}.last))
      end

      it 'sets flash notice' do
        post {{resources}}_path, params: valid_params

        expect(flash[:notice]).to be_present
      end
    end

    context 'with invalid params' do
      it 'does not create a {{resource}}' do
        expect {
          post {{resources}}_path, params: invalid_params
        }.not_to change(Db::{{Resource}}, :count)
      end

      it 'returns unprocessable entity' do
        post {{resources}}_path, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders new template' do
        post {{resources}}_path, params: invalid_params

        expect(response.body).to include('error')
      end
    end
  end

  describe 'GET /{{resources}}/:id/edit' do
    let(:{{resource}}) { create(:{{resource}}) }

    it 'returns success' do
      get edit_{{resource}}_path({{resource}})

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /{{resources}}/:id' do
    let(:{{resource}}) { create(:{{resource}}) }

    let(:valid_params) do
      {
        {{resource}}: {
          name: 'Updated Name',
        }
      }
    end

    let(:invalid_params) do
      {
        {{resource}}: {
          name: '',
        }
      }
    end

    context 'with valid params' do
      it 'updates the {{resource}}' do
        patch {{resource}}_path({{resource}}), params: valid_params

        expect({{resource}}.reload.name).to eq('Updated Name')
      end

      it 'redirects to {{resource}}' do
        patch {{resource}}_path({{resource}}), params: valid_params

        expect(response).to redirect_to({{resource}}_path({{resource}}))
      end
    end

    context 'with invalid params' do
      it 'does not update the {{resource}}' do
        original_name = {{resource}}.name

        patch {{resource}}_path({{resource}}), params: invalid_params

        expect({{resource}}.reload.name).to eq(original_name)
      end

      it 'returns unprocessable entity' do
        patch {{resource}}_path({{resource}}), params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /{{resources}}/:id' do
    let!(:{{resource}}) { create(:{{resource}}) }

    it 'deletes the {{resource}}' do
      expect {
        delete {{resource}}_path({{resource}})
      }.to change(Db::{{Resource}}, :count).by(-1)
    end

    it 'redirects to index' do
      delete {{resource}}_path({{resource}})

      expect(response).to redirect_to({{resources}}_path)
    end

    it 'sets flash notice' do
      delete {{resource}}_path({{resource}})

      expect(flash[:notice]).to be_present
    end
  end
end

# ==============================================================================
# AUTHORIZATION TESTING PATTERN
# ==============================================================================
#
# context 'when user lacks permission' do
#   let(:other_user) { create(:user) }
#   let(:{{resource}}) { create(:{{resource}}, user: other_user) }
#
#   it 'returns forbidden' do
#     delete {{resource}}_path({{resource}})
#
#     expect(response).to have_http_status(:forbidden)
#   end
# end
#
# ==============================================================================
# JSON API TESTING PATTERN
# ==============================================================================
#
# describe 'GET /api/v1/{{resources}}' do
#   it 'returns JSON' do
#     get api_v1_{{resources}}_path, headers: { 'Accept' => 'application/json' }
#
#     expect(response.content_type).to include('application/json')
#   end
#
#   it 'returns {{resources}}' do
#     create_list(:{{resource}}, 3)
#
#     get api_v1_{{resources}}_path, headers: { 'Accept' => 'application/json' }
#
#     json = JSON.parse(response.body)
#     expect(json['{{resources}}'].length).to eq(3)
#   end
# end
#
# ==============================================================================
# TURBO STREAM TESTING PATTERN
# ==============================================================================
#
# context 'with Turbo Stream request' do
#   it 'returns Turbo Stream response' do
#     post {{resources}}_path,
#          params: valid_params,
#          headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
#
#     expect(response.content_type).to include('text/vnd.turbo-stream.html')
#   end
# end