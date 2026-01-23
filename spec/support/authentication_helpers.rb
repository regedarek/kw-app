# frozen_string_literal: true

module AuthenticationHelpers
  # Create and sign in a user with specific attributes
  def sign_in_as(attributes = {})
    user = create(:user, attributes)
    sign_in(user)
    user
  end

  # Create and sign in an active member (with paid membership)
  def sign_in_active_member(attributes = {})
    user = create(:user, :with_membership, :with_profile, attributes)
    sign_in(user)
    user
  end

  # Create and sign in an admin user
  def sign_in_admin(attributes = {})
    user = create(:user, :admin, attributes)
    sign_in(user)
    user
  end

  # Create and sign in a user with specific roles
  def sign_in_with_roles(*role_names)
    user = create(:user, roles: role_names.map(&:to_s))
    sign_in(user)
    user
  end
end

RSpec.configure do |config|
  # Include authentication helpers in request specs
  # Note: Devise::Test::IntegrationHelpers already provides sign_in/sign_out
  config.include AuthenticationHelpers, type: :request
  
  # Also available in controller specs
  config.include AuthenticationHelpers, type: :controller
end