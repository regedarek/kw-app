# lib/playwright/base_helper.rb
require 'playwright'

module Playwright
  class BaseHelper
    attr_reader :playwright, :browser, :page

    def initialize(headless: true, slow_mo: 0)
      @headless = headless
      @slow_mo = slow_mo
      @console_logs = []
      @errors = []
    end

    def start
      ::Playwright.create(playwright_cli_executable_path: 'playwright') do |playwright|
        @playwright = playwright
        @browser = playwright.chromium.launch(
          headless: @headless,
          slow_mo: @slow_mo
        )
        @page = browser.new_page
        
        setup_event_listeners
        
        yield self if block_given?
        
        close
      end
    end

    def close
      @browser&.close
    end

    def goto(url)
      page.goto(url)
      page.wait_for_load_state('networkidle')
    end

    def screenshot(name)
      screenshots_dir = Rails.root.join('tmp', 'playwright', 'screenshots')
      FileUtils.mkdir_p(screenshots_dir) unless Dir.exist?(screenshots_dir)
      page.screenshot(path: screenshots_dir.join("#{name}.png").to_s)
    end

    def wait_for_element(selector)
      page.wait_for_selector(selector)
    end

    def click(selector)
      page.click(selector)
      page.wait_for_load_state('networkidle')
    end

    def fill(selector, value)
      page.fill(selector, value)
    end

    def text_content(selector)
      page.text_content(selector)
    end

    def current_url
      page.url
    end

    def title
      page.title
    end

    def has_element?(selector)
      page.query_selector(selector).present?
    rescue
      false
    end

    def console_logs
      @console_logs
    end

    def errors
      @errors
    end

    private

    def setup_event_listeners
      page.on('console', ->(msg) { @console_logs << "[#{msg.type.upcase}] #{msg.text}" })
      page.on('pageerror', ->(err) { @errors << err.to_s })
    end
  end
end