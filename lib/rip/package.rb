module Rip
  class Package
    include FileUtils

    def self.handle?(source)
      false
    end

    def self.handlers
      [ GitPackage, GemPackage ]
    end

    def self.from_source(source, *args)
      handler = handlers.detect do |klass|
        klass.handle? source
      end

      handler.new(source, *args) if handler
    end

    def self.from_hash(hash)
      package = from_source(hash.delete(:source))

      return nil if package.nil?

      # Special key.
      package.dependencies = Array(hash.delete(:dependencies)).map do |dep|
        from_hash(dep)
      end

      hash.each do |key, value|
        package.send("#{key}=", value)
      end

      package
    end

    attr_accessor :path, :source, :version, :name, :dependencies

    def initialize(source, path = nil, version = nil)
      @source  = source
      @path    = path || "/"
      @version = version

      @dependencies = []
    end

    def fetch
      raise "Override me."
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
