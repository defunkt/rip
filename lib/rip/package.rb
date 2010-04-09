module Rip
  class Package
    def self.handle?(source)
      false
    end

    def self.handlers
      [ GitPackage, GemPackage ]
    end

    def self.from_hash(hash)
      handler = handlers.detect do |klass|
        klass.handle? hash[:source]
      end

      return nil if handler.nil?

      package = handler.new(hash.delete(:source))

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
    attr_accessor :files

    def initialize(source, path = nil, version = nil)
      @source  = source
      @path    = path || "/"
      @version = version
      @files   = []

      @dependencies = []
    end

    def package_name
      "#{name}-#{Rip.md5("#{source}#{path}#{version}")}"
    end

    def package_path
      "#{Rip.packages}/#{package_name}"
    end

    def to_s
      "#{name} (#{version})"
    end
  end
end
