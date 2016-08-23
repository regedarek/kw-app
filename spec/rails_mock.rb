require 'bundler/setup'
require 'pathname'

unless defined? Rails
  module Rails
    def self.root
      Pathname.new(File.expand_path("#{__dir__}/.."))
    end

    def self.env
      'test'
    end

    def self.logger
      @logger ||= begin
        require 'logger'
        Logger.new(root.join("log/#{env}.log"))
      end
    end

    def self.cache
      nil
    end

    def self.fake?
      true
    end
  end
end
