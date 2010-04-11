module Rip
  class GemPackage < Package
    def self.handle?(source)
      source =~ /\.gem$/ || source =~ /^\w+$/
    end

    def name
      source
    end
  end
end
