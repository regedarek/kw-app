# lib/playwright/login_helper.rb
require_relative 'base_helper'

module Playwright
  class LoginHelper < BaseHelper
    CREDENTIALS = {
      development: {
        email: 'dariusz.finster@gmail.com',
        password: 'test'
      },
      staging: {
        email: 'dariusz.finster@gmail.com',
        password: 'test'
      },
      production: {
        email: 'dariusz.finster@gmail.com',
        password: 'test123'
      }
    }.freeze

    BASE_URLS = {
      development: 'http://localhost:3002',
      staging: 'http://panel.taterniczek.pl',
      production: 'https://production-url.com' # TODO: Update with actual production URL
    }.freeze

    attr_reader :environment

    def initialize(environment: :development, **options)
      super(**options)
      @environment = environment
    end

    def base_url
      BASE_URLS[environment]
    end

    def credentials
      CREDENTIALS[environment]
    end

    def login
      goto("#{base_url}/users/sign_in")
      
      # Wait for login form
      wait_for_element('input[type="email"], input[name="user[email]"], #user_email')
      
      # Try multiple possible selectors for email field
      email_selectors = [
        'input[type="email"]',
        'input[name="user[email]"]',
        '#user_email',
        'input[placeholder*="email" i]'
      ]
      
      email_field = nil
      email_selectors.each do |selector|
        if has_element?(selector)
          email_field = selector
          break
        end
      end
      
      return false unless email_field
      
      # Try multiple possible selectors for password field
      password_selectors = [
        'input[type="password"]',
        'input[name="user[password]"]',
        '#user_password',
        'input[placeholder*="password" i]'
      ]
      
      password_field = nil
      password_selectors.each do |selector|
        if has_element?(selector)
          password_field = selector
          break
        end
      end
      
      return false unless password_field
      
      # Fill in credentials
      fill(email_field, credentials[:email])
      fill(password_field, credentials[:password])
      
      # Try multiple possible selectors for submit button
      submit_selectors = [
        'input[type="submit"]',
        'button[type="submit"]',
        'input[value*="Log in" i]',
        'button:has-text("Log in")',
        'input[name="commit"]'
      ]
      
      submit_button = nil
      submit_selectors.each do |selector|
        if has_element?(selector)
          submit_button = selector
          break
        end
      end
      
      return false unless submit_button
      
      # Submit form
      click(submit_button)
      
      # Wait for redirect after login
      sleep 1
      
      # Verify login succeeded (not on login page anymore)
      !current_url.include?('/users/sign_in')
    end

    def logout
      # Try to find and click logout link
      logout_selectors = [
        'a[href="/users/sign_out"]',
        'a[data-method="delete"]',
        'a:has-text("Log out")',
        'a:has-text("Wyloguj")'
      ]
      
      logout_selectors.each do |selector|
        if has_element?(selector)
          click(selector)
          return true
        end
      end
      
      false
    end
  end
end