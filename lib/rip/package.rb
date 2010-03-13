module Rip
  class Package
    def self.handle?(source)
      false
    end

    def self.handlers
      [ GitPackage, GemPackage ]
    end

    def self.from_hash(package)
      handler = handlers.detect do |klass|
        klass.handle? package[:source]
      end

      if handler
        handler.new(package[:source], package[:path], package[:version])
      else
        nil
      end
    end

    attr_reader :path, :source, :name, :version

    def initialize(source, path = nil, version = nil, name = nil)
      @source  = source
      @path    = path || "/"
      @version = version
      @name    = name
    end

    def package_name
      "#{name}-#{Rip.md5("#{source}#{path}#{version}")}"
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

    def to_s
      "#{name} (#{version})"
    end
  end
end
