module Rip
  class GemPackage < Package
    def self.handle?(source)
      source =~ /\.gem$/ || source =~ /^\w+$/
    end

    def name
      source
    end

    def cache_name
      "#{Rip.cache}/#{source}-#{version}.gem"
    end
  end
end
