module Rip
  class GemPackage < Package
    def self.handle?(source)
      source =~ /\.gem$/ || source =~ /^\w+$/
    end

    def name
      source.split('/').last.split('-')[0...-1].join('-')
    end
  end
end
