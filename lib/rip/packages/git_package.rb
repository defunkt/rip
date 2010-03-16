module Rip
  class GitPackage < Package
    def self.handle?(source)
      source =~ /file:\/\// ||
        source =~ /git:\/\// ||
        source =~ /\.git/
    end

    def initialize(*args)
      super
      @version ||= "master"
    end

    def name
      super || source.split(%r{:|/}).last.chomp('.git')
    end
  end
end
