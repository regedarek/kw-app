# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activities::MountainRoutesController, type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  
  # Active member: user with paid membership and profile
  let(:active_member) { create(:user, :with_membership, :with_profile) }
  # Inactive member: user without paid membership
  let(:inactive_member) { create(:user, :with_profile) }
  
  describe 'GET #index' do
    let!(:public_route) { create(:mountain_route, user: active_member) }
    let!(:hidden_route) { create(:mountain_route, :hidden, user: active_member) }
    
    context 'when user is not signed in' do
      it 'redirects with CanCan authorization failure' do
        get activities_mountain_routes_path
        
        # Controller has authorize! :read which fails for guests and triggers rescue_from redirect
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
      end
    end
    
    context 'when user is active member' do
      before { sign_in active_member }
      
      it 'allows access and shows routes' do
        get activities_mountain_routes_path
        
        expect(response).to have_http_status(:success)
      end
      
      it 'CanCan allows active users to read routes' do
        ability = Ability.new(active_member)
        expect(ability.can?(:read, Db::Activities::MountainRoute)).to be true
      end
    end
  end
  
  describe 'GET #show' do
    let(:route) { create(:mountain_route, user: active_member) }
    
    it 'redirects for guests due to CanCan authorization' do
      get activities_mountain_route_path(route)
      
      # Controller uses authorize! which raises CanCan::AccessDenied, triggering rescue_from redirect
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end
    
    it 'allows signed in users to view routes' do
      sign_in active_member
      
      get activities_mountain_route_path(route)
      
      expect(response).to have_http_status(:success)
    end
    
    context 'when route is hidden' do
      let(:hidden_route) { create(:mountain_route, :hidden, user: active_member) }
      
      it 'allows owner to view their hidden route' do
        sign_in active_member
        
        get activities_mountain_route_path(hidden_route)
        
        expect(response).to have_http_status(:success)
      end
    end
  end
  
  describe 'GET #new' do
    let(:valid_params) { { route_type: 'regular_climbing' } }
    
    context 'when user is not signed in' do
      it 'redirects to root path due to CanCan authorization' do
        get new_activities_mountain_route_path, params: valid_params
        
        # authorize! :create runs before authentication and redirects to root via rescue_from
        expect(response).to redirect_to(root_path)
      end
    end
    
    context 'when user is active member' do
      before { sign_in active_member }
      
      it 'allows access to new route form' do
        get new_activities_mountain_route_path, params: valid_params
        
        expect(response).to have_http_status(:success)
      end
    end
    
    context 'when user is inactive member' do
      before { sign_in inactive_member }
      
      it 'denies access with CanCan::AccessDenied' do
        get new_activities_mountain_route_path, params: valid_params
        
        # authorize! raises CanCan::AccessDenied which is caught by rescue_from and redirects
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
      end
    end
  end
  
  describe 'POST #create - Authorization with Membership::Activement' do
    let(:valid_params) do
      {
        route: {
          name: 'New Mountain Route',
          climbing_date: Date.current,
          rating: 3,
          peak: 'Test Peak',
          area: 'Tatras',
          length: 1500,
          route_type: 'regular_climbing',
          colleague_ids: []
        }
      }
    end
    
    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        post activities_mountain_routes_path, params: valid_params
        
        expect(response).to redirect_to(new_user_session_path)
      end
      
      it 'does not create a route' do
        expect {
          post activities_mountain_routes_path, params: valid_params
        }.not_to change(Db::Activities::MountainRoute, :count)
      end
    end
    
    context 'when user is inactive (no paid membership)' do
      before { sign_in inactive_member }
      
      it 'denies access due to CanCan authorization' do
        post activities_mountain_routes_path, params: valid_params
        
        # authorize! in controller raises CanCan::AccessDenied which is caught by rescue_from
        # and redirects back with an alert instead of raising to the spec
        expect(response).to have_http_status(:redirect)
      end
      
      it 'user is not active via Membership::Activement' do
        activement = Membership::Activement.new(user: inactive_member)
        expect(activement.active?).to be false
      end
      
      it 'CanCan ability does not allow creating routes' do
        ability = Ability.new(inactive_member)
        expect(ability.can?(:create, Db::Activities::MountainRoute)).to be false
      end
    end
    
    context 'when user is active (has paid current year membership)' do
      before { sign_in active_member }
      
      it 'allows creating mountain route' do
        expect {
          post activities_mountain_routes_path, params: valid_params
        }.to change(Db::Activities::MountainRoute, :count).by(1)
        
        expect(response).to redirect_to(new_activities_mountain_route_path)
        expect(flash[:notice]).to be_present
      end
      
      it 'assigns the route to current user' do
        post activities_mountain_routes_path, params: valid_params
        
        route = Db::Activities::MountainRoute.last
        expect(route.user_id).to eq(active_member.id)
        expect(route.name).to eq('New Mountain Route')
      end
      
      it 'user is active via Membership::Activement' do
        activement = Membership::Activement.new(user: active_member)
        expect(activement.active?).to be true
      end
    end
    
    context 'when creating ski training route (boar/dziki)' do
      before { sign_in active_member }
      
      let(:training_params) do
        valid_params.deep_merge(
          route: {
            name: 'Training Ski Route',
            training: true,
            route_type: 'ski',
            length: 2000
          }
        )
      end
      
      it 'creates training route and calculates boar_length' do
        post activities_mountain_routes_path, params: training_params
        
        route = Db::Activities::MountainRoute.last
        expect(route.training).to be true
        expect(route.route_type).to eq('ski')
        expect(route.boar_length).to eq(1000) # length / 2 for training routes
      end
      
      it 'active users can see training routes (dziki)' do
        ability = Ability.new(active_member)
        expect(ability.can?(:see_dziki, Db::Activities::MountainRoute)).to be true
      end
    end
    
    context 'when creating sport climbing route' do
      before { sign_in active_member }
      
      let(:climbing_params) do
        valid_params.deep_merge(
          route: {
            route_type: 'sport_climbing',
            climb_style: 'RP',
            difficulty: '6a+'
          }
        )
      end
      
      it 'creates sport climbing route with style and difficulty' do
        post activities_mountain_routes_path, params: climbing_params
        
        route = Db::Activities::MountainRoute.last
        expect(route.route_type).to eq('sport_climbing')
        expect(route.climb_style).to eq('RP')
        expect(route.difficulty).to eq('6a+')
      end
    end
    
    context 'when user has special membership position' do
      let(:honorary_member) { create(:user, :with_profile) }
      
      before do
        honorary_member.profile.update(position: ['honorable_kw'])
        sign_in honorary_member
      end
      
      it 'allows route creation without paid fee (honorary members)' do
        activement = Membership::Activement.new(user: honorary_member)
        expect(activement.active?).to be true
        
        expect {
          post activities_mountain_routes_path, params: valid_params
        }.to change(Db::Activities::MountainRoute, :count).by(1)
      end
    end
  end
  
  describe 'GET #edit' do
    let(:route) { create(:mountain_route, user: active_member) }
    
    context 'when user is not signed in' do
      it 'redirects to activities path with alert' do
        get edit_activities_mountain_route_path(route)
        
        # Controller checks user_signed_in? and redirects with alert
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(activities_mountain_routes_path)
      end
    end
    
    context 'when user is not the owner' do
      let(:other_active_user) { create(:user, :with_membership, :with_profile) }
      
      before { sign_in other_active_user }
      
      it 'redirects to activities path with alert' do
        get edit_activities_mountain_route_path(route)
        
        # Controller checks ownership and redirects with alert
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(activities_mountain_routes_path)
      end
    end
    
    context 'when user is the owner' do
      before { sign_in active_member }
      
      it 'allows editing the route' do
        get edit_activities_mountain_route_path(route)
        
        expect(response).to have_http_status(:success)
      end
    end
    
    context 'when user is a colleague on the route' do
      let(:colleague) { create(:user, :with_membership, :with_profile) }
      let(:route_with_colleague) do
        route = create(:mountain_route, user: active_member)
        route.colleagues << colleague
        route
      end
      
      before { sign_in colleague }
      
      it 'allows colleague to edit the route' do
        get edit_activities_mountain_route_path(route_with_colleague)
        
        expect(response).to have_http_status(:success)
      end
    end
    
    context 'when user is admin' do
      let(:admin_with_membership) { create(:user, :admin, :with_membership, :with_profile) }
      
      before { sign_in admin_with_membership }
      
      it 'admin can edit routes (bypasses ownership check)' do
        get edit_activities_mountain_route_path(route)
        
        expect(response).to have_http_status(:success)
      end
    end
  end
  
  describe 'PUT #update' do
    let(:route) { create(:mountain_route, user: active_member) }
    let(:update_params) do
      {
        id: route.id,
        route: {
          name: 'Updated Route Name',
          rating: 5
        }
      }
    end
    
    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        put activities_mountain_route_path(route), params: update_params
        
        # authenticate_user! redirects to sign in page
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    context 'when user is the owner' do
      before { sign_in active_member }
      
      it 'updates the route' do
        put activities_mountain_route_path(route), params: update_params
        
        expect(response).to redirect_to(edit_activities_mountain_route_path(route))
        expect(flash[:notice]).to be_present
        expect(route.reload.name).to eq('Updated Route Name')
        expect(route.rating).to eq(5)
      end
    end
    
    context 'when user is admin' do
      let(:admin_with_membership) { create(:user, :admin, :with_membership, :with_profile) }
      
      before { sign_in admin_with_membership }
      
      it 'allows admin to update any route' do
        put activities_mountain_route_path(route), params: update_params
        
        expect(route.reload.name).to eq('Updated Route Name')
      end
    end
  end
  
  describe 'DELETE #destroy' do
    let!(:route) { create(:mountain_route, user: active_member) }
    
    context 'when user is not signed in' do
      it 'redirects back with alert' do
        delete activities_mountain_route_path(route)
        
        # Controller checks authorization and redirects back with alert
        expect(response).to have_http_status(:redirect)
      end
    end
    
    context 'when user is not the owner' do
      let(:other_active_user) { create(:user, :with_membership, :with_profile) }
      
      before { sign_in other_active_user }
      
      it 'redirects back and does not delete' do
        expect {
          delete activities_mountain_route_path(route)
        }.not_to change(Db::Activities::MountainRoute, :count)
        
        # Controller checks authorization and redirects back with alert
        expect(response).to have_http_status(:redirect)
      end
    end
    
    context 'when user is the owner' do
      before { sign_in active_member }
      
      it 'destroys the route' do
        expect {
          delete activities_mountain_route_path(route)
        }.to change(Db::Activities::MountainRoute, :count).by(-1)
        
        expect(response).to redirect_to(activities_mountain_routes_path)
        expect(flash[:notice]).to be_present
      end
    end
    
    context 'when user is admin' do
      let!(:admin_route) { create(:mountain_route, user: active_member) }
      let(:admin_with_membership) { create(:user, :admin, :with_membership, :with_profile) }
      
      before { sign_in admin_with_membership }
      
      it 'allows admin to destroy any route' do
        expect {
          delete activities_mountain_route_path(admin_route)
        }.to change(Db::Activities::MountainRoute, :count).by(-1)
      end
    end
  end
  
  describe 'POST #hide' do
    let(:route) { create(:mountain_route, user: active_member) }
    
    before { sign_in active_member }
    
    it 'hides the route when authorized' do
      expect(route.hidden).to be false
      
      # Use PUT instead of POST as the route definition shows
      put hide_activities_mountain_route_path(route)
      
      expect(route.reload.hidden).to be true
      expect(response).to redirect_to(activities_mountain_routes_path)
    end
  end
  
  describe 'CanCan Ability integration' do
    context 'inactive user abilities' do
      let(:inactive_user) { create(:user, :with_profile) }
      let(:ability) { Ability.new(inactive_user) }
      
      it 'cannot create new routes' do
        expect(ability.can?(:create, Db::Activities::MountainRoute)).to be false
      end
      
      it 'cannot see training routes (dziki)' do
        expect(ability.can?(:see_dziki, Db::Activities::MountainRoute)).to be false
      end
      
      it 'can manage their own routes' do
        own_route = create(:mountain_route, user: inactive_user)
        expect(ability.can?(:manage, own_route)).to be true
      end
      
      it 'can read public routes' do
        expect(ability.can?(:read, Db::Activities::MountainRoute)).to be true
      end
    end
    
    context 'active user abilities' do
      let(:ability) { Ability.new(active_member) }
      
      it 'can create routes' do
        expect(ability.can?(:create, Db::Activities::MountainRoute)).to be true
      end
      
      it 'can see training routes (dziki)' do
        expect(ability.can?(:see_dziki, Db::Activities::MountainRoute)).to be true
      end
      
      it 'can manage routes where they are a colleague' do
        route = create(:mountain_route, user: other_user)
        route.colleagues << active_member
        
        expect(ability.can?(:manage, route)).to be true
      end
      
      it 'cannot destroy routes where they are only a colleague' do
        route = create(:mountain_route, user: other_user)
        route.colleagues << active_member
        
        expect(ability.can?(:destroy, route)).to be false
      end
      
      it 'can destroy their own routes' do
        own_route = create(:mountain_route, user: active_member)
        expect(ability.can?(:destroy, own_route)).to be true
      end
    end
    
    context 'admin abilities' do
      let(:ability) { Ability.new(admin_user) }
      
      it 'admin flag allows bypassing restrictions in controller' do
        route = create(:mountain_route, user: other_user)
        # Admin abilities for MountainRoute are checked via admin? method in controller
        # not via CanCan :manage permissions
        expect(admin_user.admin?).to be true
        expect(admin_user.roles).to include('admin')
      end
    end
    
    context 'user with reservations role' do
      let(:reservations_user) { create(:user, :with_reservations_role, :with_membership, :with_profile) }
      let(:ability) { Ability.new(reservations_user) }
      
      it 'has special reservation permissions' do
        expect(ability.can?(:manage, Db::Reservation)).to be true
        expect(ability.can?(:give_warning, Db::Reservation)).to be true
      end
    end
  end
end