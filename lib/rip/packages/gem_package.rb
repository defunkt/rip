module Rip
  class GemPackage < Package
    def self.handle?(source)
      source =~ /^\w+$/
    end

    def name
      source
    end

    def cache_name
      "#{name}-#{version}.gem"
    end
  end
end
