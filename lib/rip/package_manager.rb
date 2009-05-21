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
      message << "#{@name} requested at #{@bad_version} by #{@requester}"

      if @owners.size == 1
        owners = @owners[0]
      elsif @owners.size == 2
        owners = "#{@owners[0]} and #{@owners[1]}"
      else
        owners = [ @owners[0...-1], "and #{@owners[-1]}" ].join(', ')
      end

      message << "#{@name} previously requested at #{@real_version} by #{owners}"
      message.join("\n")
    end
    alias_method :to_s, :message
  end

  class PackageManager
    attr_reader :lineage, :heritage, :sources, :versions

    def initialize(env = nil)
      @env = env || Rip::Env.active
      load

      # key is the package name, value is the current
      # installed version
      @versions ||= {}

      # key is the package name, value is an array of
      # libraries it depend on
      @heritage ||= {}

      # key is the package name, value is an array of
      # libraries that depend on it
      @lineage ||= {}

      # key is the package name, value is the source
      @sources ||= {}

      # key is the package name, value is the installed
      # files
      @files ||= {}
    end

    def packages
      @versions.keys.map { |name| package(name) }
    end

    def package(name)
      return unless @sources[name]
      Package.for(@sources[name], @versions[name], @files[name])
    end

    def packages_that_depend_on(name)
      (@lineage[name] || []).map { |name| package(name) }
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
        raise VersionConflict.new(name, version, parent, @versions[name], @heritage[name])
      end

      if parent && !parent.meta_package?
        @heritage[name] ||= Set.new
        @heritage[name].add(parent.name)
        @lineage[parent.name] ||= Set.new
        @lineage[parent.name].add(name)
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
      Array(@heritage[name]).each do |dep|
        @lineage[dep].delete(name) if @lineage[dep].respond_to? :delete
      end

      @heritage.delete(name)
      @lineage.delete(name)
      @versions.delete(name)
      save
    end

    def path
      File.join(Rip.dir, @env, "#{@env}.ripenv")
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
      Marshal.dump [ @versions, @heritage, @lineage, @sources, @files ]
    end

    def marshal_read(data)
      @versions, @heritage, @lineage, @sources, @files = Marshal.load(data)
    end
  end
end
