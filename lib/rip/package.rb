require 'digest/md5'

#
# Want to write your own package?
#
# Check Rip::PackageAPI for the methods you need.
#

module Rip
  class Package
    include PackageAPI, Memoize

    @@patterns = {}
    @@blocks = {}

    def self.handles(*patterns, &block)
      patterns.each do |pattern|
        @@patterns[pattern] = self
      end

      @@blocks[self] = block if block
    end

    def self.for(source, version = nil)
      source = source.strip.chomp

      handler = @@patterns.detect do |pattern, klass|
        source.match(pattern)
      end

      return handler[1].new(source, version) if handler

      handler = @@blocks.detect do |klass, block|
        block.call(source)
      end

      handler[0].new(source, version) if handler
    end

    alias_method :to_s, :name
    attr_reader :source

    def initialize(source, version = nil)
      @source = source.strip.chomp
      @version = version
    end

    memoize :cache_name
    def cache_name
      name + '-' + Digest::MD5.hexdigest(@source)
    end

    memoize :cache_path
    def cache_path
      File.join(packages_path, cache_name)
    end

    memoize :packages_path
    def packages_path
      File.join(Rip.dir, 'rip-packages')
    end

    def installed?(version = nil)
      graph = DependencyManager.new

      if version
        graph.package_version(name) == version
      else
        graph.installed?(name)
      end
    end

    def files
      fetch
      unpack

      Dir[File.join(cache_path, 'lib/*')] + Dir[File.join(cache_path, 'bin/*')]
    end

    def dependencies
      if File.exists? deps = File.join(cache_path, 'deps.rip')
        File.readlines(deps).map do |line|
          source, version, *extra = line.split(' ')
          Package.for(source, version)
        end
      else
        []
      end
    end

    def puts(msg)
      super "rip: #{msg}"
    end

    def abort(msg)
      super "rip: #{msg}"
    end
  end
end
