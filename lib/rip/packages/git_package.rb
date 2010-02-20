module Rip
  class GitPackage
    attr_reader :source

    def initialize(source, version = nil)
      @source  = source
      @version = version
    end

    def name
      source.split('/').last.chomp('.git')
    end

    def version
      @version
    end

    def package_name
      "#{name}-#{Rip.md5("#{source}#{version}")}"
    end

    def package_path
      "#{Rip.packages}/#{package_name}"
    end

    def cache_name
      "#{name}-#{Rip.md5(source)}"
    end

    def cache_path
      "#{Rip.cache}/#{cache_name}"
    end
  end
end
