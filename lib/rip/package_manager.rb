require 'zlib'
require 'set'

module Rip
  class VersionConflict < RuntimeError
    def initialize(name, bad_version, requester, real_version, owners)
      @name = name
      @bad_version = bad_version
      @requester = requester
      @real_version = real_version
      @owners = owners
    end

    def message
      message = []
      message << "version conflict!"

      requested  = "#{@name} requested at #{@bad_version}"
      requested += " by #{@requester}" if @requester
      message << requested

      if @owners.size == 1
        owners = @owners[0]
      elsif @owners.size == 2
        owners = "#{@owners[0]} and #{@owners[1]}"
      elsif @owners.size > 2
        owners = [ @owners[0...-1], "and #{@owners[-1]}" ].join(', ')
      end

      previously_requested  = "#{@name} previously requested at #{@real_version}"
      previously_requested += " by #{owners}" if owners
      message << previously_requested

      message.join("\n")
    end
    alias_method :to_s, :message
  end

  class PackageManager
    attr_reader :dependencies, :dependents, :sources, :versions, :env

    def initialize(env = nil)
      @env = env || Rip::Env.active
      load

      # key is the package name, value is the current
      # installed version
      @versions ||= {}

      # key is the package name, value is an array of
      # libraries it depend on
      @dependents ||= {}

      # key is the package name, value is an array of
      # libraries that depend on it
      @dependencies ||= {}

      # key is the package name, value is the source
      @sources ||= {}

      # key is the package name, value is the installed
      # files
      @files ||= {}
    end

    def inspect
      "(#{self.class} dependencies=#{dependencies.inspect} dependents=#{dependents.inspect} sources=#{sources.inspect} versions=#{versions.inspect})"
    end

    def packages
      @versions.keys.map { |name| package(name) }
    end

    def package_names
      @versions.keys
    end

    def package(name)
      return unless @versions[name]
      Package.for(@sources[name], @versions[name], @files[name])
    end

    def packages_that_depend_on(name)
      (@dependents[name] || []).map { |name| package(name) }
    end

    def files(name)
      Array(@files[name])
    end

    def installed?(name)
      @versions.has_key? name
    end

    def package_version(name)
      @versions[name]
    end

    def add_package(package, parent = nil)
      name = package.name
      version = package.version

      if @versions.has_key?(name) && @versions[name] != version
        raise VersionConflict.new(name, version, parent, @versions[name], @dependents[name].to_a)
      end

      if parent && !parent.meta_package?
        @dependents[name] ||= Set.new
        @dependents[name].add(parent.name)
        @dependencies[parent.name] ||= Set.new
        @dependencies[parent.name].add(name)
      end

      # already installed?
      if @versions.has_key? name
        false
      else
        @versions[name] = version
        @sources[name] = package.source
        @files[name] = package.files
        true
      end
    ensure
      save
    end

    def add_files(name, file_list = [])
      @files[name] ||= []
      @files[name].concat file_list
      save
    end

    def remove_package(package)
      name = package.name

      Array(@dependencies[name]).each do |dep|
        @dependents[dep].delete(name) if @dependents[dep].respond_to? :delete
      end

      @dependents.delete(name)
      @dependencies.delete(name)
      @versions.delete(name)
      save
    end

    def path
      File.join(dir, "#{@env}.ripenv")
    end

    def dir
      File.join(Rip.dir, @env)
    end

    def save
      File.open(path, 'w') do |f|
        f.puts zip(marshal_payload)
        f.flush
      end
    end

    def load
      marshal_read unzip(File.read(path)) if File.exists? path
    end

    def zip(data)
      Zlib::Deflate.deflate(data)
    end

    def unzip(data)
      Zlib::Inflate.inflate(data)
    end

    def marshal_payload
      Marshal.dump [ @versions, @dependents, @dependencies, @sources, @files ]
    end

    def marshal_read(data)
      @versions, @dependents, @dependencies, @sources, @files = Marshal.load(data)
    end
  end
end
